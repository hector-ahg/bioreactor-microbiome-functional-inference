# Inferred functional potential predicts medium-chain carboxylic acid production in mixed microbial communities

Scripts supporting the analysis in this publication: 16S amplicon processing 
(QIIME2 + PICRUSt2) and downstream functional inference plotting. Processing 
was run separately for four experiments due to different sequencing primers: 
**inocula (rumen and wine pure cultures)**, **proportions (rumen and wine mixtures: r20w80, r50w50,r80w20)**, **SV (SBR acclimatization and acidification stages)**, and **SVR (SBR batch stages)**.

## Structure

### Shell workflow (QIIME2 / PICRUSt2)

Numbered scripts indicate pipeline order. Each step was run separately per 
experiment (suffix indicates which: `inocula`, `proportions`, `SV`, `SVR`).

| Step | Purpose | Scripts |
|------|---------|---------|
| 01 | Setup / core functions | `01_functions_qiime_picrust_corrected_*.sh` |
| 02 | DADA2 truncation length sweep | `02_dada2_truncation_sweep_*.sh` |
| 03 | Taxonomic classification | `03_qiime2_classification_corrected_*.sh` |
| 04 | Functional prediction (PICRUSt2) | `04_picrust2_*.sh` |


`classifier` – trained taxonomic classifier used in step 03.

### `python/`

Notebooks generating the publication figures from functional inference output:
- `plotting_functional_inference_publication_inocula_and_proportions_v7.ipynb`
- `plotting_functional_inference_publication_SBR_v7.ipynb`
- `fig1_combining_script.ipynb`

## Usage

Run scripts in numeric order (`01` → `04`) for the relevant experiment suffix. 
Each experiment's workflow is independent end-to-end due to primer-specific 
processing.

## Citation

If you use these scripts, please cite:

> [Author list]. *Inferred functional potential predicts medium-chain 
> carboxylic acid production in mixed microbial communities.* [Journal, year, DOI]