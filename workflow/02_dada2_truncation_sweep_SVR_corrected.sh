# 5. DADA2 truncation sweep
RESULTS="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/SVR"
INPUT="$RESULTS/demux-trimmed_SVR.qza"
THREADS=2

TRUNC_PAIRS=("280 250" "275 245" "283 250")

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
    --o-table "$OUTDIR/table_SVR.qza" \
    --o-representative-sequences "$OUTDIR/rep-seqs_SVR.qza" \
    --o-denoising-stats "$OUTDIR/stats_SVR.qza" \
    --o-base-transition-stats "$OUTDIR/base-stats_SVR.qza" \
    --verbose \
    &> "$OUTDIR/dada2_SVR.log"
done


for D in "$RESULTS"/dada2_trimmed_F*/; do
  echo "=== $D ==="
  qiime metadata tabulate \
    --m-input-file "$D/stats_SVR.qza" \
    --o-visualization "$D/stats_SVR.qzv"
done