#!/usr/bin/bash

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

dir_index="/mnt/MERSEA/Ref/Oyster_Genome/Sanger_bowtie2_indexes"
dir_reads=${baseDir}/ATAC-seq/data_processing/trim_out
dir_out=${baseDir}/data_processing/bowtie2_out

function align {

	echo -e "\n------------ alignement de $1 ------------\n"

	bowtie2 -p 8 -x "${dir_index}/Sanger_genome" \
	-1 "${dir_reads}/$1_trim_fw_paired.fastq.gz" \
	-2 "${dir_reads}/$1_trim_rev_paired.fastq.gz" \
	-U "${dir_reads}/$1_trim_fw_unpaired.fastq.gz", "${dir_reads}/$1_trim_rev_unpaired.fastq.gz" \
	-S "${dir_out}/$1_aligned.sam"

}

for (sample in "${samples[@]}"); do
	align ${sample};
done
