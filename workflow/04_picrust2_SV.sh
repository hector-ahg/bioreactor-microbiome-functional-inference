# 8. PICRUSt2 (run in picrust2 env)
# Activate environment manually before running this part:
# conda activate picrust2



SV_DIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/SV/dada2_trimmed_F255_R220/"

# Remove any previous failed/partial run
rm -rf "$SV_DIR/picrust2_out"

# Run PICRUSt2 -- ensure seqs_export was generated from rep-seqs-filtered.qza

picrust2_pipeline.py \
  -s "$SV_DIR/seqs_export/dna-sequences.fasta" \
  -i "$SV_DIR/table_export/feature-table.biom" \
  -o "$SV_DIR/picrust2_out" \
  -p 2 \
  --stratified

echo "PICRUSt2 completed!"