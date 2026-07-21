# 8. PICRUSt2 (run in picrust2 env)
# Activate environment manually before running this part:
# conda activate picrust2



PROPORTIONS_DIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_1_checked/proportions/dada2_trimmed_F245_R183"

# Remove any previous failed/partial run
rm -rf "$PROPORTIONS_DIR/picrust2_out"

# Run PICRUSt2 -- ensure seqs_export was generated from rep-seqs-filtered.qza

picrust2_pipeline.py \
  -s "$PROPORTIONS_DIR/seqs_export/dna-sequences.fasta" \
  -i "$PROPORTIONS_DIR/table_export/feature-table.biom" \
  -o "$PROPORTIONS_DIR/picrust2_out" \
  -p 2 \
  --stratified

echo "PICRUSt2 completed!"