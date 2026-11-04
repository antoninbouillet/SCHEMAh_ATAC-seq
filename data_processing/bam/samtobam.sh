#!/usr/bin/bash

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

dir_sam=${baseDir}/bowtie2_out/
dir_bam=${baseDir}/bam

function samtobam {

	samtools view -b -@ 16 "${dir_sam}/$1_aligned.sam" > "${dir_bam}/$1_aligned.bam"
 
}

for (sample in "${samples[@]}"); do
	samtobam $sample
done
