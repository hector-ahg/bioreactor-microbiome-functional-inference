# ================================

# Pendent

qiime empress tree-plot \
    --i-tree /Users/hector/Documents/LIPATA_HH/Metabolic_inference/Secuenciaciones/dada2_180/tree/rooted_tree.qza \
    --o-visualization /Users/hector/Documents/LIPATA_HH/Metabolic_inference/Secuenciaciones/dada2_180/tree/empress.qzv



qiime diversity core-metrics-phylogenetic \
    --i-table ./table_180_filt.qza \
    --i-phylogeny tree/rooted_tree.qza \
    --p-sampling-depth 10000 \
    --m-metadata-file data/metadata.tsv \
    --output-dir diversity


!qiime diversity alpha-group-significance \
    --i-alpha-diversity diversity/shannon_vector.qza \
    --m-metadata-file data/metadata.tsv \
    --o-visualization diversity/alpha_groups.qzv

