#!/usr/bin/bash

#définition du chemin d'accès de fastqc
#PATH="${PATH:+${PATH}:}/home/anton/bin/FastQC"

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
out_dir=${baseDir}/data_processing/fastqc_out/pre_trim
fastq_dir=${baseDir}/data_processing/fastq

for file in $(find $fastq_dir -type f);
do
	echo $file
	fastqc $file -o $out_dir
done






