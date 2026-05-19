# Tetracycline toxicogenomics — analysis README

RNA-seq analysis of rat liver after 4-day high-dose tetracycline exposure.
Data: **GSE144219** (Rx-TGx, Merck & Co.), Han Wistar male rats, 600 mg/kg/day, n=3 vs n=3.

## Files

| File | Purpose |
|------|---------|
| `tetracycline_analysis.R` | Full pipeline: import → EDA → RUV → DEA → GSEA |
| `data/galaxy_featureCounts.tabular` | **You provide.** Galaxy export of the count matrix |
| `results/` | All figures, tables, and session info (generated) |

## Suggested repo layout

```
tetracycline-toxicogenomics/
├── R/
│   └── tetracycline_analysis.R
├── data/
│   └── galaxy_featureCounts.tabular     # not committed if large
├── results/                              # gitignored
├── docs/
│   └── report.md
├── README.md
└── .gitignore
```

Tag the final commit (`git tag v1.0 && git push --tags`) to satisfy the "release tag" checkpoint.

## Pipeline rationale

**Filtering.** `filterByExpr` keeps genes with enough counts to support
a reliable DE test given the smallest group (n=3). For rat liver this
typically retains ~14–17 k genes from the ~30 k starting set.

**Normalization.** TMM (`calcNormFactors`) is robust to composition
bias caused by a few highly expressed genes dominating one condition —
common with high-dose hepatotoxicants.

**RUVSeq.** With six samples and no spike-ins, the **empirical
control genes** strategy is the right choice: a first-pass edgeR fit
identifies the genes least affected by treatment, which then serve as
in-silico negative controls for `RUVg`. We use **k = 1** because more
latent factors risk absorbing real biology in a 6-sample design.

⚠️ **Sanity check:** if `cor(W$W_1, treatment)` is high (>0.7), the
latent factor is capturing the treatment effect itself — drop the
controls that are most correlated with treatment or reduce k to 0.

**DEA.** edgeR quasi-likelihood (`glmQLFit` / `glmQLFTest`) with
robust dispersion estimation. The W factor enters the design *alongside*
treatment, so its variance is regressed out while the coefficient of
interest stays interpretable.

**GSEA.** `multiGSEA` runs a single ranked-list enrichment across KEGG,
Reactome, and WikiPathways, then combines per-pathway p-values with
Stouffer's method — gives more stable hits than relying on any single
database.

## What you should see (biology)

Tetracycline at this dose hits liver hard. Predictable signatures:

- **↓ Oxidative phosphorylation / mitochondrial translation** —
  tetracyclines inhibit 70S-like mitochondrial ribosomes. This is the
  mechanism behind tetracycline-associated microvesicular steatosis.
- **↓ Fatty-acid β-oxidation, PPARα targets** — blocked OXPHOS forces
  triglyceride accumulation. Look for *Cpt1a, Acox1, Hadha, Ehhadh,
  Cyp4a* family.
- **↑ Phase I/II xenobiotic metabolism** — *Cyp1a, Cyp2b, Cyp3a, Gst,
  Ugt, Sult* families; "Drug metabolism — cytochrome P450" pathway.
- **↑ Nrf2 / oxidative stress** — *Nqo1, Hmox1, Gclc, Gclm, Txnrd1*.
- **↑ Mitochondrial UPR / chaperones** — *Hspd1, Hspe1, Clpp, Lonp1,
  Atf5*. Specific signature of impaired mito proteostasis.
- **↑ Acute-phase / inflammation** — at this dose, hepatocellular
  damage triggers it (*Saa, Cxcl, Lcn2, Il6*).
- **Mixed ribosome signal** — cytoplasmic ribosome genes may rise as a
  compensatory response.

If the top hits don't include several of these, suspect an issue with
sample assignment, alignment, or RUV factor sign.

## Common pitfalls

1. **Sample order mismatch.** Galaxy column order ≠ your metadata
   order. The script enforces this with `stopifnot()`, but double-check
   the mapping from SRR/SRX → GSM. The metadata table in the script is
   the source of truth.

2. **Gene ID format.** Ensembl IDs sometimes carry a version suffix
   (`ENSRNOG…G.7`). The script strips it before annotation. If your
   featureCounts used a different GTF, the IDs may not match
   `org.Rn.eg.db` and many will be `NA` — switch annotation source
   (e.g. `AnnotationHub` Ensembl 94 dump) if mapping rate is bad.

3. **n = 3 dispersion estimation.** Robust dispersion (`robust = TRUE`)
   is essential. Don't switch to exactTest — the GLM-QL approach
   handles small n far better.

4. **multiGSEA database fetch.** First run downloads pathway data from
   the web; if your network blocks it, switch to `useLocal = TRUE`
   after caching with `graphite::pathways(...)`.

## Outputs at a glance

| File | What it is |
|------|------------|
| `01_library_sizes.pdf` | Sanity check on read depth |
| `02_RLE_pre_RUV.pdf` | Unwanted variation before correction |
| `03_PCA_pre_RUV.pdf` | Sample separation before RUV |
| `04_sample_distance_heatmap.pdf` | Pairwise sample similarity |
| `05_RLE_post_RUV.pdf` | Should be tighter than (02) |
| `06_PCA_post_RUV.pdf` | Should show cleaner treatment separation |
| `07_volcano.pdf` | DE overview with top genes labelled |
| `08_MDplot.pdf` | Mean-difference plot |
| `09_top_DE_heatmap.pdf` | Top 50 DE genes, centered logCPM |
| `10_top_pathways.pdf` | Top enriched pathways (multiGSEA) |
| `DE_results.csv` | Full DE table |
| `multiGSEA_results.csv` | Full pathway-level enrichment |
| `pathways_of_interest.csv` | Filtered to tetracycline-relevant pathways |
| `sessionInfo.txt` | R / package versions (for reproducibility) |
