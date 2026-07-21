#!/usr/bin/env bash

# Paths
CLASSIFIER="/Users/hector/git/bioreactor-microbiome-functional-inference/workflow/classifier/silva-138-99-nb-classifier.qza"

DATASET="SVR"        # change to SVR when needed

DADA2_RESULTS_DIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/${DATASET}/dada2_trimmed_F275_R245"

TABLE="${DADA2_RESULTS_DIR}/table_${DATASET}.qza"
REP_SEQS="${DADA2_RESULTS_DIR}/rep-seqs_${DATASET}.qza"

qiime feature-table filter-samples \
  --i-table "$TABLE" \
  --p-min-frequency 1000 \
  --o-filtered-table "$DADA2_RESULTS_DIR/table-filtered-samples.qza"

qiime feature-table filter-features \
  --i-table "$DADA2_RESULTS_DIR/table-filtered-samples.qza" \
  --p-min-frequency 10 \
  --o-filtered-table "$DADA2_RESULTS_DIR/table-filtered-final.qza"

# NEW: keep rep-seqs in sync with the filtered table
qiime feature-table filter-seqs \
  --i-data "$REP_SEQS" \
  --i-table "$DADA2_RESULTS_DIR/table-filtered-final.qza" \
  --o-filtered-data "$DADA2_RESULTS_DIR/rep-seqs-filtered.qza"

qiime feature-table summarize \
  --i-table "$DADA2_RESULTS_DIR/table-filtered-final.qza" \
  --o-visualization "$DADA2_RESULTS_DIR/table-filtered-final.qzv"

qiime tools export \
  --input-path "$DADA2_RESULTS_DIR/table-filtered-final.qza" \
  --output-path "$DADA2_RESULTS_DIR/table_export"

qiime tools export \
  --input-path "$DADA2_RESULTS_DIR/rep-seqs-filtered.qza" \
  --output-path "$DADA2_RESULTS_DIR/seqs_export"

qiime feature-classifier classify-sklearn \
  --i-reads "$DADA2_RESULTS_DIR/rep-seqs-filtered.qza" \
  --i-classifier "$CLASSIFIER" \
  --p-n-jobs 2 \
  --o-classification "$DADA2_RESULTS_DIR/taxa.qza"

qiime tools export \
  --input-path "$DADA2_RESULTS_DIR/taxa.qza" \
  --output-path "$DADA2_RESULTS_DIR/taxa_export"

biom convert \
  -i "$DADA2_RESULTS_DIR/table_export/feature-table.biom" \
  -o "$DADA2_RESULTS_DIR/table_export/feature-table.tsv" \
  --to-tsv