# CodingAssignment_Tetracycline

RNA-seq-Auswertung der Tetracyclin-Hepatotoxizität in der Rattenleber — eine Kursarbeit zur Toxikogenomik. Das Repository enthält eine vollständige Downstream-Pipeline in R/Bioconductor (differentielle Expression, Batch-Korrektur, Pathway-Anreicherung) sowie die zugehörigen Eingangsdaten, Abbildungen und Berichte. Die vorgelagerte Read-Verarbeitung wurde in Galaxy durchgeführt.

## Worum geht es

Untersucht wird, wie eine Tetracyclin-Exposition das Lebertranskriptom der Ratte verändert. Ausgewertet wird der öffentliche Datensatz GSE144219 (Rattus norvegicus, Referenzgenom Rnor_6.0/rn6), männliche Rattenleber, 4 Kontrollen gegen 4 mit Tetracyclin behandelte Tiere. Der Datensatz stammt aus Podtelezhnikov et al. 2020 (Toxicological Sciences 175(1):98–112, doi:10.1093/toxsci/kfaa026).

Das Projekt verfolgt zwei parallele Auswertungswege und vergleicht sie:

- R: Qualitätskontrolle und explorative Analyse, differentielle Expression mit DESeq2, Korrektur unerwünschter Variation mit RUVSeq, Pathway-Anreicherung mit multiGSEA (Reactome, KEGG) und fgsea (MSigDB Hallmark).
- Galaxy (vorgelagert): Reads-to-Counts und referenzbasierte Zählung; das Ergebnis ist die Count-Matrix, die in `data/` liegt.

## Datensatz und Probenzuordnung

| Gruppe | GSM | SRR |
|---|---|---|
| control | GSM4283620–GSM4283623 | SRR11025983–SRR11025986 |
| tetracycline | GSM4283624–GSM4283627 | SRR11025987–SRR11025990 |

Die maßgebliche Zuordnung liegt als Tabelle in `documents/` (`zuweisungstab_tetracycline.ods`).

## Repository-Struktur

- `scripts/` : das R-Analyseskript (R-Markdown). Enthält die komplette Downstream-Pipeline sowie die Galaxy-Schritte als dokumentierte Beschreibung.
- `data/` : Eingangsdaten: die Count-Matrix aus Galaxy (`galaxy_featurecounts.tabular`, ca. 33000 Gene × 8 Proben), Ergebnis-/Vergleichsdateien des Enrichment (multiGSEA- und Hallmark-Tabellen der Pipeline (R) auf den originalen MERCK-Count-Datentsatz
- `output/`: vom Skript erzeugte Abbildungen (durchnummeriert, z. B. `01_library_size.png`, `04_meanSd_vst.png`, `06_pca_vst.png`, `08_volcano.png`) und exportierte Ergebnistabellen, Galaxy-goseq-Ausgaben für KEGG und GO, Ausgaben der R-Pipeline auf den MERCK-Count-Datensatz
- `documents/`: Zuweisungstabelle, SRR_list_tetracycline


Pfadkonvention: Das Skript läuft aus dem Projektordner heraus und spricht die Daten relativ an — Eingaben über `data/`, Ausgaben über `output/` (`fig_dir <- "output"`). Wird das Skript aus `scripts/` heraus ausgeführt, müssen die relativen Pfade entsprechend angepasst werden.

## Voraussetzungen

R (Version 4.x) mit Bioconductor. Die zentralen Pakete:

- Daten und Infrastruktur: `SummarizedExperiment`, `SingleCellExperiment`, `data.table`, `dplyr`
- DE und Transformation: `DESeq2`, `edgeR`, `vsn`
- Batch-Korrektur: `RUVSeq`, `EDASeq`
- Anreicherung: `multiGSEA`, `msigdbr`
- Annotation: `AnnotationDbi`, `org.Rn.eg.db`
- Visualisierung: `ggplot2`, `ggrepel`, `RColorBrewer`, `ComplexHeatmap`, `iSEE`

## Wie das R-Skript funktioniert

nähere Beschreibung im RMD-Skript

## Ausführen

Das R-Markdown-Dokument in `scripts/` öffnen und entweder vollständig knitten oder einzelne Chunks interaktiv ausführen. Zum tatsächlichen Rechnen die Chunk-Option `eval` auf `TRUE` setzen und sicherstellen, dass `data/` die Count-Matrix enthält und `output/` existiert.

