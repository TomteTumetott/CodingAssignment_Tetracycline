###########
#Packages 
############
# Run once (uncomment):
#install.packages("BiocManager")
#BiocManager::install(c(
#   "SummarizedExperiment", "edgeR", "RUVSeq", "EDASeq",
#   "AnnotationDbi", "org.Rn.eg.db",
#   "multiGSEA", "graphite", "rWikiPathways",
#   "pheatmap", "RColorBrewer", "ggplot2", "ggrepel"
# ))

suppressPackageStartupMessages({
  library(SummarizedExperiment)
  library(edgeR)
  library(RUVSeq)
  library(EDASeq)
  library(AnnotationDbi)
  library(org.Rn.eg.db)
  library(multiGSEA)
  library(graphite)
  library(pheatmap)
  library(RColorBrewer)
  library(ggplot2)
  library(ggrepel)
})

set.seed(13)

outdir <- "results"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)