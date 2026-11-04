#!/usr/bin/bash

source /home/bouille251/venv_deeptools/bin/activate

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
norm_dir=${baseDir}/data_processing/BigWig/normalized
raw_dir=${baseDir}/data_processing/BigWig/raw

genes="/mnt/MERSEA/Ref/Oyster_Genome/Sanger_free/genes.bed"

sample_names="5a1 5a2 5a3 C1 C2 C3 dg1"
sample_list_norm="5a1_normalized.bw 5a2_normalized.bw 5a3_normalized.bw C1_normalized.bw C2_normalized.bw C3_normalized.bw dg1_normalized.bw"
sample_list_raw="5a1_raw.bw 5a2_raw.bw 5a3_raw.bw C1_raw.bw C2_raw.bw C3_raw.bw dg1_raw.bw"
color_list="#f0d16d #f0d16d #f0d16d #6d8cf0 #6d8cf0 #6d8cf0 #EC7E70"

#données normalisées

cd $norm_dir

computeMatrix scale-regions \
-S $sample_list_norm \
-p 16 \
--regionBodyLength 2500 \
--missingDataAsZero \
--skipZeros \
--upstream 500 \
--downstream 500 \
-R $genes \
-o ${norm_dir}/matrix_normalized.gz

plotProfile \
--matrixFile matrix_normalized.gz \
--outFileName 'profile_genes_2500bp.pdf' \
--colors $color_list \
--numPlotsPerRow 3 \
--plotTitle 'Coverage of normalized ATAC-seq reads whithin genes' \
--yAxisLabel 'mean coverage' \
--averageType mean \
--plotType se 


plotHeatmap \
--matrixFile matrix_normalized.gz \
--outFileName 'heatmap_genes_2500bp.pdf' \
--plotTitle 'Coverage of normalized ATAC-seq reads whithin genes' \
--plotType se

multiBigwigSummary BED-file \
--bwfiles $sample_list_norm \
--smartLabels \
--binSize 10000 \
--BED $genes \
--outFileName summary_genes_norm.npz


plotPCA \
--corData summary_genes_norm.npz \
--plotFile PCA_genes_normalized.pdf \
--plotTitle 'PCA of normalized ATAC-seq reads within genes' \
--rowCenter \
--ntop 0 \
--colors $color_list


wait 

#données brutes

cd $raw_dir

computeMatrix scale-regions \
-S $sample_list_raw \
-p 16 \
--regionBodyLength 2500 \
--missingDataAsZero \
--skipZeros \
--upstream 500 \
--downstream 500 \
-R $genes \
-o ${raw_dir}/matrix_raw.gz
EOF


plotProfile \
--matrixFile matrix_raw.gz \
--outFileName 'profile_genes_2500bp.pdf' \
--colors $color_list \
--numPlotsPerRow 3 \
--plotTitle 'Coverage of raw ATAC-seq reads whithin genes' \
--yAxisLabel 'mean coverage' \
--averageType mean \
--plotType se 

plotHeatmap \
--matrixFile matrix_raw.gz \
--outFileName 'heatmap_genes_2500bp.pdf' \
--plotTitle 'Coverage of raw ATAC-seq reads whithin genes' \
--plotType se


multiBigwigSummary BED-file \
--bwfiles $sample_list_raw \
--smartLabels \
--binSize 10000 \
--BED $genes \
--outFileName summary_genes_raw.npz

plotPCA \
--corData summary_genes_raw.npz \
--plotFile PCA_genes_raw.pdf \
--plotTitle 'PCA of raw ATAC-seq reads within genes' \
--rowCenter \
--ntop 0 \
--colors $color_list
