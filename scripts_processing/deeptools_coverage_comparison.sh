#!/usr/bin/bash

source /home/bouille251/venv_deeptools/bin/activate

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
bam_dir=${baseDir}/data_processing/bam_filtered

cd $bam_dir

bam_list="5a1_filtered.bam 5a2_filtered.bam 5a3_filtered.bam C1_filtered.bam C2_filtered.bam C3_filtered.bam dg1_filtered.bam dg2_filtered.bam"
labels="5a1 5a2 5a3 C1 C2 C3 dg1 dg2"

plotCoverage \
-p 16 \
-b $bam_list \
-o covergage_comp.pdf \
-l $labels
