#!/bin/bash
set -euo pipefail

# Paths
PROJECT="/Users/hector/git/bioreactor-microbiome-functional-inference"
SEQUENCES_SBR_DIR="$PROJECT/data/Secuenciaciones/1_Sharon_Batch_inoculos_y_proporcion"
RESULTS="$PROJECT/results/results_1_checked/proportions"
MANIFEST="$RESULTS/manifest_proportions.tsv"
 
FORWARD_PRIMER="ACGCGHNRAACCTTACC"   # B969F, V6–V8 # for proportions
REVERSE_PRIMER="ACGGGCRGTGWGTRCAA"   # BA1406R, V6–V8 # for proportions

#FORWARD_PRIMER="GTGCCAGCMGCCGCGGTAA" # 515F, V4–V6
#REVERSE_PRIMER="GGACTACHVGGGTWTCTAAT"  # 806R, V4–V6

#FORWARD_PRIMER="CCTACGGGNGGCWGCAG" # 341F, V3–V4 
#REVERSE_PRIMER="GACTACHVGGGTATCTAATCC"  # 805R, V3–V4

#FORWARD_PRIMER="AGAGTTTGATCMTGGCTCAG"    # 27F # for inocula
#REVERSE_PRIMER="TGCTGCCTCCCGTAGGAGT"    # 338R # for inocula

# 1. Import (PAIRED-END) 
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path "$MANIFEST" \
  --output-path "$RESULTS/paired-end-demux.qza" \
  --input-format PairedEndFastqManifestPhred33V2
echo ">> Imported. Next: inspect quality."

# 2. Quality summary of RAW reads
qiime demux summarize \
  --i-data "$RESULTS/paired-end-demux.qza" \
  --o-visualization "$RESULTS/demux-summary.qzv"
echo ">> Open demux-summary.qzv and check quality BEFORE trimming"

# 3. Primer trimming (B969F / BA1406R, V6–V8)
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences "$RESULTS/paired-end-demux.qza" \
  --p-front-f "$FORWARD_PRIMER" \
  --p-front-r "$REVERSE_PRIMER" \
  --p-match-adapter-wildcards \
  --p-discard-untrimmed \
  --p-error-rate 0.1 \
  --p-overlap 10 \
  --p-cores 0 \
  --o-trimmed-sequences "$RESULTS/demux-trimmed.qza" \
  --verbose \
  &> "$RESULTS/cutadapt-report.txt"
echo ">> Trimmed. Check cutadapt-report.txt for % reads with adapters"

# 4. Quality summary of TRIMMED reads (verify primer removal) 
qiime demux summarize \
  --i-data "$RESULTS/demux-trimmed.qza" \
  --o-visualization "$RESULTS/demux-trimmed-summary.qzv"
echo ">> Compare lengths: trimmed reads should be ~17 bp shorter"


