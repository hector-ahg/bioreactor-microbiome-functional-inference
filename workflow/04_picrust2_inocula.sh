# 8. PICRUSt2 (run in picrust2 env)
# Activate environment manually before running this part:
# conda activate picrust2


INOCULA_DIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_1_checked/inocula/dada2_trimmed_F260_R215"

# Remove any previous failed/partial run
rm -rf "$INOCULA_DIR/picrust2_out"

# Run PICRUSt2 -- ensure seqs_export was generated from rep-seqs-filtered.qza

picrust2_pipeline.py \
  -s "$INOCULA_DIR/seqs_export/dna-sequences.fasta" \
  -i "$INOCULA_DIR/table_export/feature-table.biom" \
  -o "$INOCULA_DIR/picrust2_out" \
  -p 2 \
  --stratified

echo "PICRUSt2 completed!"