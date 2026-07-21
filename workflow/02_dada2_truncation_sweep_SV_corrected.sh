# 5. DADA2 truncation sweep
RESULTS="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/SV"
INPUT="$RESULTS/demux-trimmed_SV.qza"
THREADS=2

TRUNC_PAIRS=("245 220" "240 220")

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
    --o-table "$OUTDIR/table_SV.qza" \
    --o-representative-sequences "$OUTDIR/rep-seqs_SV.qza" \
    --o-denoising-stats "$OUTDIR/stats_SV.qza" \
    --o-base-transition-stats "$OUTDIR/base-stats_SV.qza" \
    --verbose \
    &> "$OUTDIR/dada2_SV.log"
done

for D in "$RESULTS"/dada2_trimmed_F*/; do
  echo "=== $D ==="
  qiime metadata tabulate \
    --m-input-file "$D/stats_SV.qza" \
    --o-visualization "$D/stats_SV.qzv"
done