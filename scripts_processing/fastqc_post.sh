#!/usr/bin/bash

#définition du chemin d'accès de fastqc
#PATH="${PATH:+${PATH}:}/home/anton/bin/FastQC"

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
out_dir=${baseDir}/data_processing/fastqc_out/post_trim
trim_dir=${baseDir}/data_processing/trim_out

for file in $(find $trim_dir -type f);
do
	echo $file
	fastqc $file -o $out_dir
done



