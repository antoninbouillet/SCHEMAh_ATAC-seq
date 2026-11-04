#!/usr/bin/bash

dg1="/mnt/MERSEA/work/wk_SCHEMAh/wk_SCHEMAh_ADN/ATAC-seq/bam/chromosomes/dg1/"

dg2="/mnt/MERSEA/work/wk_SCHEMAh/wk_SCHEMAh_ADN/ATAC-seq/bam/chromosomes/dg2/"

function get_chr {

	for chr in $(find $1 -type f); do
	
		echo $chr
	
		samtools flagstat $chr > ${sample}"$chr"_stats.txt
	done
}


get_chr dg1
get_chr dg2

