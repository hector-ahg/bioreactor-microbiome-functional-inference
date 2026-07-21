#!/bin/bash
set -euo pipefail

# Paths
PROJECT="/Users/hector/git/bioreactor-microbiome-functional-inference"
SEQUENCES_SBR_DIR="$PROJECT/data/Secuenciaciones/3_Sharon_SBR"
RESULTS="$PROJECT/results/results_3_checked/SV"
MANIFEST="$RESULTS/manifest_SV.tsv"

FORWARD_PRIMER="ACGCGHNRAACCTTACC"   # B969F, V6–V8
REVERSE_PRIMER="ACGGGCRGTGWGTRCAA"   # BA1406R, V6–V8

#FORWARD_PRIMER="GTGCCAGCMGCCGCGGTAA" # 515F, V4–V6
#REVERSE_PRIMER="GGACTACHVGGGTWTCTAAT"  # 806R, V4–V6

#FORWARD_PRIMER="CCTACGGGNGGCWGCAG" # 341F, V3–V4 
#REVERSE_PRIMER="GACTACHVGGGTATCTAATCC"  # 805R, V3–V4

# 1. Import (PAIRED-END) 
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path "$MANIFEST" \
  --output-path "$RESULTS/paired-end-demux_SV.qza" \
  --input-format PairedEndFastqManifestPhred33V2
echo ">> Imported. Next: inspect quality."

# 2. Quality summary of RAW reads
qiime demux summarize \
  --i-data "$RESULTS/paired-end-demux_SV.qza" \
  --o-visualization "$RESULTS/demux-summary_SV.qzv"
echo ">> Open demux-summary.qzv and check quality BEFORE trimming"

# 3. Primer trimming (B969F / BA1406R, V6–V8)
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences "$RESULTS/paired-end-demux_SV.qza" \
  --p-front-f "$FORWARD_PRIMER" \
  --p-front-r "$REVERSE_PRIMER" \
  --p-match-adapter-wildcards \
  --p-discard-untrimmed \
  --p-error-rate 0.1 \
  --p-overlap 10 \
  --p-cores 0 \
  --o-trimmed-sequences "$RESULTS/demux-trimmed_SV.qza" \
  --verbose \
  &> "$RESULTS/cutadapt-report_SV.txt"
echo ">> Trimmed. Check cutadapt-report_SV.txt for % reads with adapters"

# 4. Quality summary of TRIMMED reads (verify primer removal) 
qiime demux summarize \
  --i-data "$RESULTS/demux-trimmed_SV.qza" \
  --o-visualization "$RESULTS/demux-trimmed-summary_SV.qzv"
echo ">> Compare lengths: trimmed reads should be ~17 bp shorter"


