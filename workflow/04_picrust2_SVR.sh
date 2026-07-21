# 8. PICRUSt2 (run in picrust2 env)
# Activate environment manually before running this part:
# conda activate picrust2

SVR_DIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/SVR/dada2_trimmed_F275_R245/"

# Remove any previous failed/partial run
rm -rf "$SVR_DIR/picrust2_out"

# Run PICRUSt2 -- ensure seqs_export was generated from rep-seqs-filtered.qza

picrust2_pipeline.py \
  -s "$SVR_DIR/seqs_export/dna-sequences.fasta" \
  -i "$SVR_DIR/table_export/feature-table.biom" \
  -o "$SVR_DIR/picrust2_out" \
  -p 2 \
  --stratified

echo "PICRUSt2 completed!"