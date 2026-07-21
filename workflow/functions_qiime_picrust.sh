# 1. Import data
# Choose ONE depending on your data

# # ---- If SINGLE-END (keep this if correct) ----
# qiime tools import \
#   --type 'SampleData[SequencesWithQuality]' \
#   --input-path data/manifest.tsv \
#   --output-path single-end-demux.qza \
#   --input-format SingleEndFastqManifestPhred33V2

#---- If PAIRED-END (uncomment if needed) ----
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path /Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_2/manifest.tsv \
  --output-path /Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_2/paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

# If primers were removed during Illumina sequence, do not use Cutadapt.

# 2. Quality summary
qiime demux summarize \
  --i-data "/Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_2/paired-end-demux.qza" \
  --o-visualization "/Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_2/demux-summary.qzv"

echo "Check visualization of sequence quality"




# Primer trimming with Cutadapt

# Define primers
FORWARD_PRIMER = "ACGCGHNRAACCTTACC"  # B969F amplified regions V6-V8 of the 16S rRNA gene (16S rDNA). 
# FORWARD_PRIMER = "GTGCCAGCMGCCGCGGTAA" #515F
REVERSE_PRIMER = "ACGGGCRGTGWGTRCAA"  # BA1406R amplified regions V6-V8 of the 16S rRNA gene (16S rDNA). 
# REVERSE_PRIMER = "GGACTACHVGGGTWTCTAAT"  # 806R


qiime cutadapt trim-paired \
  --i-demultiplexed-sequences "/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/paired-end-demux.qza" \
  --p-front-f "FORWARD_PRIMER" \
  --p-front-r "REVERSE_PRIMER" \
  --p-match-adapter-wildcards \
  --p-error-rate 0.1 \
  --p-overlap 10 \
  --o-trimmed-sequences "/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/demux-trimmed.qza" \
  --verbose


# 2. Quality summary
qiime demux summarize \
  --i-data "/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/demux-trimmed.qza" \
  --o-visualization "/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/demux-trimmed-summary.qzv"

echo "Check visualization of sequence quality"






# 3. DADA2 truncation sweep
RESULTS="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked"
INPUT="$RESULTS/demux-trimmed.qza"
THREADS=2

TRUNC_PAIRS=("250 205" "245 200" "250 210")

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

echo "All DADA2 runs completed!"

# 4. Visualize denoising stats
qiime metadata tabulate \
  --m-input-file /Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/dada2_trimmed_F280_R225/stats_SV.qza \
  --o-visualization /Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_checked/dada2_trimmed_F280_R225/stats_SV.qzv


# 5. Summarize feature tables (NOT working)
qiime feature-table summarize \
  --i-table table.qza \
  --output-dir summary

# optional. If there are samples with low frequency 

qiime feature-table filter-samples \
  --i-table table.qza \
  --p-min-frequency 2000 \
  --o-filtered-table table-filtered-samples.qza

# Filter low-abundance features 
qiime feature-table filter-features \
  --i-table table-filtered-samples.qza \
  --p-min-frequency 25 \
  --o-filtered-table table-filtered-final.qza

# Summarize
qiime feature-table summarize \
  --i-table table-filtered-final.qza \
  --output-dir summary-filtered-final


# 7. Export for PICRUSt2
# Feature table
unzip table-filtered-final.qza -d table_export

# Sequences
unzip rep-seqs.qza -d seqs_export



 ## The following code runs DADA2 for pair end.

INPUT="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/demux-trimmed.qza"
THREADS=2

TRUNC_F=(240 250 260)
TRUNC_R=(220 230 240)

for F in "${TRUNC_F[@]}"; do
  for R in "${TRUNC_R[@]}"; do

    OUTDIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/dada2_${F}_${R}"
    mkdir -p "$OUTDIR"

    echo "Running DADA2 F=$F R=$R"

    qiime dada2 denoise-paired \
      --i-demultiplexed-seqs "$INPUT" \
      --p-trunc-len-f "$F" \
      --p-trunc-len-r "$R" \
      --p-n-threads "$THREADS" \
      --o-table "${OUTDIR}/table_trimmed.qza" \
      --o-representative-sequences "${OUTDIR}/rep-seqs_trimmed.qza" \
      --o-denoising-stats "${OUTDIR}/stats_trimmed.qza" \
      --o-base-transition-stats "${OUTDIR}/base-stats_trimmed.qza" \
      --verbose

    qiime metadata tabulate \
      --m-input-file "${OUTDIR}/stats_trimmed.qza" \
      --o-visualization "${OUTDIR}/stats_trimmed.qzv"

    # 5. Summarize feature tables (NOT working)
    qiime feature-table summarize \
      --i-table "${OUTDIR}/table_trimmed.qza" \
      --output-dir "${OUTDIR}/summary" 


  done
done



# 8. PICRUSt2 (run in picrust2 env)
# Activate environment manually before running this part:
# conda activate picrust2

# Convert BIOM
biom convert \
  -i /Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/dada2_260/exported-table/feature-table.biom \
  -o /Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/dada2_260/exported-table/table.tsv \
  --to-tsv

# Run PICRUSt2
picrust2_pipeline.py \
  -s /Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_3_standard/dada2_180/seqs_export/92a4fcf4-28cd-4523-a45c-d9f568bee415/data/dna-sequences.fasta \
  -i /Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_3_standard/dada2_180/table_export/f76f5430-d262-4c33-bfa4-b0ce046f5f78/data/table.biom \
  -o /Users/hector/Documents/LIPATA_HH/Metabolic_inference/results/results_3_standard/dada2_180/picrust2_out \
  -p 2 \
  --stratified


echo "PICRUSt2 completed!"







TRUNC_F=(240 250 260)
TRUNC_R=(220 230 240)

for F in "${TRUNC_F[@]}"; do
  for R in "${TRUNC_R[@]}"; do

    OUTDIR="/Users/hector/git/bioreactor-microbiome-functional-inference/results/results_3_standard/dada2_${F}_${R}"
    mkdir -p "$OUTDIR"

    echo "Running DADA2 F=$F R=$R"

    qiime metadata tabulate \
      --m-input-file "${OUTDIR}/stats.qza" \
      --o-visualization "${OUTDIR}/stats.qzv"

    # 5. Summarize feature tables (NOT working)
    qiime feature-table summarize \
      --i-table "${OUTDIR}/table.qza" \
      --output-dir "${OUTDIR}/summary" 


  done
done



