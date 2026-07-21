# 5. DADA2 truncation sweep
RESULTS="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_1_checked/proportions"
INPUT="$RESULTS/demux-trimmed.qza"
THREADS=2

TRUNC_PAIRS=("256 185" "245 183")

for PAIR in "${TRUNC_PAIRS[@]}"; do
  read -r TF TR <<< "$PAIR"
  OUTDIR="$RESULTS/dada2_trimmed_F${TF}_R${TR}"
  echo ">> denoise-paired  trunc-f=${TF}  trunc-r=${TR}"
  mkdir -p "$OUTDIR"
  qiime dada2 denoise-paired \
    --i-demultiplexed-seqs "$INPUT" \
    --p-trunc-len-f "$TF" \
    --p-trunc-len-r "$TR" \
    --p-n-threads "$THREADS" \
    --o-table "$OUTDIR/table.qza" \
    --o-representative-sequences "$OUTDIR/rep-seqs.qza" \
    --o-denoising-stats "$OUTDIR/stats.qza" \
    --o-base-transition-stats "$OUTDIR/base-stats.qza" \
    --verbose \
    &> "$OUTDIR/dada2.log"
done


for D in "$RESULTS"/dada2_trimmed_F*/; do
  echo "=== $D ==="
  qiime metadata tabulate \
    --m-input-file "$D/stats.qza" \
    --o-visualization "$D/stats.qzv"
done