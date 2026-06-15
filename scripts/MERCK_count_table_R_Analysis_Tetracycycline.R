
## PAKETE laden


## Bioconductor
library(SummarizedExperiment)  # SummarizedExperiment(), assay(), colData()
library(DESeq2)                # DESeqDataSet(), estimateSizeFactors(), vst(), DESeq(), results(), plotPCA()
library(vsn)                   # meanSdPlot()   (hexbin nur INSTALLIERT nötig, nicht attached)
library(ComplexHeatmap)        # Heatmap(), columnAnnotation()
library(EDASeq)                # newSeqExpressionSet(), betweenLaneNormalization(), plotRLE(), plotPCA(), counts()  -> lädt Biobase mit
library(RUVSeq)                # RUVg(), RUVs(), RUVr(), makeGroups()
library(edgeR)                 # DGEList(), calcNormFactors(), glmFit(), glmLRT(), topTags(), residuals()
library(multiGSEA)             # initOmicsDataStructure(), rankFeatures(), getMultiOmicsFeatures(), multiGSEA(), extractPvalues()
library(AnnotationDbi)         # mapIds()
library(org.Rn.eg.db)          # Annotations-DB Ratte
library(SingleCellExperiment)  # reducedDim() + as(dds, "SingleCellExperiment")
library(iSEE)                  # iSEE()  (zieht die Shiny-/DT-Kette intern als Imports)
library(GEOquery)              #  nur zum Auflösen GSM -> US-ID + Treatment

## CRAN
library(ggplot2)               # alle QC-Plots
library(RColorBrewer)          # brewer.pal()
library(data.table)            # res[order(padj)], copy(), fwrite()
library(msigdbr)               # msigdbr()  (HALLMARK-Teil)
library(dplyr)                 # %>%, select(), filter()  (zuletzt: maskiert AnnotationDbi::select bewusst)


## 0.  Merck/GEO-Count-Matrix (GSE144219) einlesen + Proben wählen

## 0.1 vorab: Count-Matrix laden
## GSE144219_Rx-TGx_Count.txt : Spalte1 GeneID (ENSRNOG), Spalte2 GeneName,
## Spalten 3..745 = 743 Proben (US-IDs). Pfad anpassen.
raw <- read.delim("data/og_counts_merck_ncbi_GSE133219/GSE144219_Rx-TGx.Count.txt", check.names = FALSE)

id2sym <- setNames(raw$GeneName, raw$GeneID)        # Symbol-Lookup (ersetzt org.Rn.eg.db, s.u.)
rownames(raw) <- raw$GeneID
counts_all <- as.matrix(raw[, !(colnames(raw) %in% c("GeneID","GeneName"))])

## RSEM "expected counts" sind teils NICHT ganzzahlig -> runden (DESeq2/edgeR brauchen Integer!)
storage.mode(counts_all) <- "double"
counts_all <- round(counts_all)
mode(counts_all) <- "integer"

##0.2 Die 8 Proben der Tetracyclin-Studie (TT12-9732) einbauen
gsms <- c("GSM4283620", "GSM4283621","GSM4283622","GSM4283623",                # erwartet: Vehikel-Kontrolle
          "GSM4283624","GSM4283625","GSM4283626","GSM4283627")   # erwartet: Tetracyclin

meta <- lapply(gsms, function(g) Meta(getGEO(g))); names(meta) <- gsms
us_id     <- vapply(meta, function(m) sub(".*\\[(US-[0-9]+)\\].*","\\1", m$title), "")
treatment <- vapply(meta, function(m){
  sub("treatment:\\s*","", grep("treatment:", m$characteristics_ch1, value=TRUE)[1])
}, "")

print(data.frame(gsm=gsms, us=us_id, treatment=treatment, row.names=NULL))  # <- einmal prüfen!

## 0.3  Matrix auf diese 7 reduzieren, Spalten in GSM umbenennen
stopifnot(all(us_id %in% colnames(counts_all)))     # sind alle US-IDs da?
counts <- counts_all[, us_id]
colnames(counts) <- gsms
colnames(counts)
## 0.4  condition AUTOMATISCH aus dem treatment-Feld 
condition <- factor(ifelse(grepl("control", treatment, ignore.case=TRUE), "control","treated"),
                    levels = c("control","treated"))
coldata <- data.frame(condition = condition, row.names = colnames(counts))
print(table(coldata$condition))                     # erwartet: control 4, treated 4 




## A)  EXPLORATORY ANALYSIS & QC

## Experiment aufbauen (entspricht dem geladenen ***.rds im Tutorial)
se <- SummarizedExperiment(assays = list(counts = counts), colData = coldata)

##Remove unexpressed genes: > 5 total counts ueber alle Proben
nrow(se)
se <- se[rowSums(assay(se, "counts")) > 5, ]
nrow(se)

##Library size differences
#plot lib size 
se$libSize <- colSums(assay(se))

colData(se) |>
  as.data.frame() |>
  ggplot(aes(x = rownames(colData(se)), y = libSize / 1e6, fill = condition)) +
  geom_bar(stat = "identity") + theme_bw() +
  labs(x = "Sample", y = "Total count in millions") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))

## DESeqDataSet + Size factors (Normalisierung fuer Library size + RNA-Komposition)
dds <- DESeq2::DESeqDataSet(se, design = ~ condition)
dds <- estimateSizeFactors(dds)

ggplot(data.frame(libSize    = colSums(assay(dds)),
                  sizeFactor = sizeFactors(dds),
                  condition  = dds$condition),
       aes(x = libSize, y = sizeFactor, col = condition)) +
  geom_point(size = 5) + theme_bw() +
  labs(x = "Library size", y = "Size factor")

##ransform data: Varianz-Stabilisierung
meanSdPlot(assay(dds), ranks = FALSE)              # vor Transformation: Varianz steigt mit Mittelwert

vsd <- DESeq2::vst(dds, blind = TRUE)
meanSdPlot(assay(vsd), ranks = FALSE)              # nach VST: flach

##Heatmaps and clustering (Euklidische Distanz zwischen Proben)
dst    <- dist(t(assay(vsd)))
colors <- colorRampPalette(brewer.pal(9, "Blues"))(255)
ComplexHeatmap::Heatmap(
  as.matrix(dst),
  col            = colors,
  name           = "Euclidean\ndistance",
  cluster_rows   = hclust(dst),
  cluster_columns = hclust(dst),
  bottom_annotation = columnAnnotation(
    condition = vsd$condition,
    col = list(condition = c(control = "yellow", treated = "purple")))
)

## PCA
pcaData    <- DESeq2::plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
ggplot(pcaData, aes(x = PC1, y = PC2)) +
  geom_point(aes(color = condition), size = 5) +
  theme_minimal() +
  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
  ylab(paste0("PC2: ", percentVar[2], "% variance")) +
  coord_fixed()

## B)  REMOVE UNWANTED VARIATION   (RUVSeq-Vignette)


##Filtering: > 5 Reads in >= 2 Proben (exakt wie Vignette)
filter   <- apply(counts, 1, function(x) length(x[x > 5]) >= 2)
filtered <- counts[filter, ]
genes    <- rownames(filtered)            # alle Gene als "Kontrollset" (keine ERCC vorhanden)

##SeqExpressionSet
x   <- as.factor(c(rep("Ctl", 4), rep("Trt", 4)))   # condition
set <- newSeqExpressionSet(
  as.matrix(filtered),
  phenoData = data.frame(x, row.names = colnames(filtered))
)
set

##Exploratory: RLE + PCA (vor Normalisierung
colors <- brewer.pal(3, "Set2")
plotRLE(set, outline = FALSE, ylim = c(-4, 4), col = colors[x])
plotPCA(set, col = colors[x], cex = 1.2)

##Upper-quartile-Normalisierung (between-sample)
set <- betweenLaneNormalization(set, which = "upper")
plotRLE(set, outline = FALSE, ylim = c(-4, 4), col = colors[x])
plotPCA(set, col = colors[x], cex = 1.2)

## Empirische Kontrollgene bestimmen (erster edgeR-Durchlauf)
design <- model.matrix(~x, data = pData(set))
y <- DGEList(counts = counts(set), group = x)
y <- calcNormFactors(y, method = "upperquartile")
y <- estimateGLMCommonDisp(y, design)
y <- estimateGLMTagwiseDisp(y, design)
fit <- glmFit(y, design)
lrt <- glmLRT(fit, coef = 2)

top       <- topTags(lrt, n = nrow(set))$table
empirical <- rownames(set)[which(!(rownames(set) %in% rownames(top)[1:5000]))]

##RUVg mit empirischen Kontrollgenen (k = 1)
set2 <- RUVg(set, empirical, k = 1)
pData(set2)
plotRLE(set2, outline = FALSE, ylim = c(-4, 4), col = colors[x])
plotPCA(set2, col = colors[x], cex = 1.2)

##DE-Analyse mit edgeR, inkl. Faktor der unerwuenschten Variation W_1
design <- model.matrix(~x + W_1, data = pData(set2))
y <- DGEList(counts = counts(set2), group = x)
y <- calcNormFactors(y, method = "upperquartile")
y <- estimateGLMCommonDisp(y, design)
y <- estimateGLMTagwiseDisp(y, design)
fit <- glmFit(y, design)
lrt <- glmLRT(fit, coef = 2)          # coef 2 = Effekt von x (Trt vs Ctl)
topTags(lrt)

##Dieselbe DE-Analyse mit DESeq2 (W_1 im Design)
dds_ruv <- DESeqDataSetFromMatrix(
  countData = counts(set2),
  colData   = pData(set2),
  design    = ~ W_1 + x
)
dds_ruv <- DESeq(dds_ruv)
res_ruv <- results(dds_ruv)
res_ruv <- res_ruv[order(res_ruv$padj), ]
head(res_ruv)

## RUVs (replicate samples)
differences <- makeGroups(x)          # gruppiert Ctl-Replikate und Trt-Replikate
set3 <- RUVs(set, genes, k = 1, differences)
pData(set3)

##RUVr (residuals eines ersten GLM)
design <- model.matrix(~x, data = pData(set))
y <- DGEList(counts = counts(set), group = x)
y <- calcNormFactors(y, method = "upperquartile")
y <- estimateGLMCommonDisp(y, design)
y <- estimateGLMTagwiseDisp(y, design)
fit <- glmFit(y, design)
res <- residuals(fit, type = "deviance")
set4 <- RUVr(set, genes, k = 1, res)
pData(set4)


## C)  PATHWAY-ENRICHMENT   (multiGSEA-Vignette) — Organismus = Ratte
##
## ...es gibt nur nur einen Omics-Layer (transcriptome). Input sind die DE-Resultate
## aus B) (DESeq2 mit RUV-Korrektur): Gen-Symbol, logFC, p-value.




##E-Ergebnis -> benoetigtes Format: Symbol / logFC / pValue 
de <- as.data.frame(res_ruv)
de$ENSEMBL <- rownames(de)
de <- de[!is.na(de$pvalue), ]

## Ensembl-Gen-IDs (ENSRNOG...) -> Gene-Symbol mappen (Ratte: org.Rn.eg.db)
de$Symbol <- mapIds(org.Rn.eg.db,
                    keys     = de$ENSEMBL,
                    column   = "SYMBOL",
                    keytype  = "ENSEMBL",
                    multiVals = "first")
de <- de[!is.na(de$Symbol) & !duplicated(de$Symbol), ]

transcriptome <- data.frame(Symbol = de$Symbol,
                            logFC  = de$log2FoldChange,
                            pValue = de$pvalue)

##atenstruktur + Pre-Ranking
## rankFeatures: ls = sign(log2FC) * log10(pValue)
omics_data <- initOmicsDataStructure(layer = c("transcriptome"))
omics_data$transcriptome <- rankFeatures(transcriptome$logFC, transcriptome$pValue)
names(omics_data$transcriptome) <- transcriptome$Symbol

##Pathway-Definitionen laden (KEGG + Reactome), Features als SYMBOL ########takes time
databases <- c("kegg", "reactome")
layers    <- names(omics_data)

pathways <- getMultiOmicsFeatures(
  dbs                 = databases,
  layer               = layers,
  returnTranscriptome = "SYMBOL",
  organism            = "rnorvegicus",   # <- Ratte
  useLocal            = FALSE
)

enrichment_scores <- multiGSEA(pathways, omics_data)
###
df <- extractPvalues(enrichment_scores, pathwayNames = names(pathways[[1]]))
df$combined_pval <- df$transcriptome_pval         # kein Kombinieren nötig
df$combined_padj <- df$transcriptome_padj
df <- cbind(pathway = names(pathways[[1]]), df)
df <- df[order(df$combined_padj), ]
head(df, 15)

# Speichern der Ergebnisse
write.csv(df, "output/output_MERCK_og_featurecounts/MERCK_data_multiGSEA_pathway_results.csv", row.names = FALSE)


#Auswertung der Richtung NES und Treibergene
library(data.table)
res <- enrichment_scores$transcriptome[order(padj)]

res[padj < 0.05, .(pathway, NES, padj, size)]          # NES-Vorzeichen = Richtung

# gezielt die Tetracyclin-relevanten Themen + ihre Richtung:
res[grepl("lipid|fatty acid|oxidative phosphoryl|respiratory electron|mitochondrial translation|ATF4|EIF2|PERK|GCN2|amino acid|cholesterol|TCA|citric", pathway, ignore.case = TRUE),
    .(pathway, NES, padj)]

# Treibergene eines Treffers:
res[pathway == "(REACTOME) Metabolism of lipids", leadingEdge][[1]]


#richtungskonventionen checken
transcriptome[transcriptome$Symbol %in% c("Eif4ebp3","Fasn"), ]   # logFC-Vorzeichen ...
omics_data$transcriptome[c("Eif4ebp3","Fasn")]                    # ... muss zum rank-Vorzeichen passen


## (Optional) Custom Gene Sets: HALLMARK fuer Ratte ueber MSigDB
#nochmal über Hallmark DB abgleichen. komm das gleiche bei raus wie bei reactome / kegg?

#install.packages("msigdbr")
library(msigdbr); library(dplyr)
hallmark <- msigdbr(species = "Rattus norvegicus", category = "H") %>%
  dplyr::select(gs_name, ensembl_gene) %>%
  dplyr::filter(!is.na(ensembl_gene)) %>%
  unstack(ensembl_gene ~ gs_name)
pathways_h <- list("transcriptome" = hallmark)
# # ranks dann nach ENSEMBL benennen statt SYMBOL.

## 2. Ranks nach ENSEMBL (HALLMARK ist Ensembl-basiert, nicht SYMBOL!)
de_ens <- as.data.frame(res_ruv)
de_ens$ENSEMBL <- rownames(de_ens)
de_ens <- de_ens[!is.na(de_ens$pvalue) & !duplicated(de_ens$ENSEMBL), ]

ranks_ens <- initOmicsDataStructure("transcriptome")
ranks_ens$transcriptome <- rankFeatures(de_ens$log2FoldChange, de_ens$pvalue)
names(ranks_ens$transcriptome) <- de_ens$ENSEMBL

## 3. Enrichment
es_h  <- multiGSEA(pathways_h, ranks_ens)
res_h <- es_h$transcriptome[order(padj)]

## 4. Signifikante Treffer ansehen (NES-Vorzeichen = Richtung: + hoch, - runter)
res_h[padj < 0.05, .(pathway, NES, padj, size)]

## 5. Als TSV speichern (leadingEdge ist Listen-Spalte -> vorher zu Text)
out <- copy(res_h)
out$leadingEdge <- sapply(out$leadingEdge, paste, collapse = ";")
fwrite(out, "output/output_MERCK_og_featurecounts/MERCK_data_hallmark_multiGSEA_results.tsv", sep = "\t")


sessionInfo()

