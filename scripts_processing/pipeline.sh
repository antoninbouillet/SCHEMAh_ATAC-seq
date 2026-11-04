#!/usr/bin/bash

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
scriptDir=${baseDir}/scripts_processing
dataDir=${baseDir}/data_processing

echo -e "\n------------ 1er QC ------------\n"
${scriptDir}/fastqc_pre.sh
${dataDir}/fastqc_out/pre_trim/multiqc.sh

echo -e "\n------------ trim des adapters avec Trimmomatic ------------\n"
${scriptDir}/trim.sh

echo -e "\n------------ 2nd QC ------------\n"
${scriptDir}/fastqc_post.sh
${dataDir}/fastqc_out/post_trim/multiqc.sh

echo -e "\n------------ alignement avec bowtie2 ------------\n"
${scriptDir}/alignement.sh
${dataDir}/bam/samtobam.sh

echo -e "\n------------ annotation des reads dupliqués ------------\n"
${scriptDir}/markdup.sh
${dataDir}/bam/multiqc.sh

echo -e "\n------------ retrait reads dupliqués & non alignés ( + autres filtres) ------------\n"
${scriptDir}/bam_filter.sh
${dataDir}/bam_filtered/multiqc.sh

echo -e "\n------------ conversion en BigWig et tracé du coverage au niveau des gènes ------------\n"
${scriptDir}/deeptools_coverage_comparison.sh
${scriptDir}/bam_coverage.sh
${scriptDir}/deeptools_matrix_plots.sh

echo -e "\n------------ décodage des régions ouvertes avec macs3 ------------\n"
${scriptDir}/bam_to_bedpe.sh
${scriptDir}/callpeak.sh
${scriptDir}/hmmratac.sh
