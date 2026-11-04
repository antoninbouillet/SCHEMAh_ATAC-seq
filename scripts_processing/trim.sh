#!/usr/bin/bash

trimmomatic_source="/home/bouille251/Trimmomatic/trimmomatic.jar"
baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

in_dir=${baseDir}/data_processing/fastq
out_dir=${baseDir}/data_processing/trim_out

#fonction pour ne conserver qu'un seul read si read R1 = read R2
:'
function trim {

	local fastq_pre=$1
	local fastq_post=$2
	
	java -jar $trimmomatic_source \
	PE \
	${in_dir}/${fastq_pre}_R1_001.fastq.gz \
	${in_dir}/${fastq_pre}_R2_001.fastq.gz \
	${out_dir}/${fastq_post}_trim_fw_paired.fastq.gz \
	${out_dir}/${fastq_post}_trim_fw_unpaired.fastq.gz \
	${out_dir}/${fastq_post}_trim_rev_paired.fastq.gz \
	${out_dir}/${fastq_post}_trim_rev_unpaired.fastq.gz \
	ILLUMINACLIP:NexteraPE-PE.fa:2:30:10 \
	LEADING:3 \
	TRAILING:3 \
	SLIDINGWINDOW:4:15 \
	MINLEN:20	
}
'

#fonction pour conserver les reads en tant que paires, même si read R1 = read R2
function trim {

	local fastq_pre=$1
	local fastq_post=$2
	
	java -jar $trimmomatic_source \
	PE \
	${in_dir}/${fastq_pre}_R1_001.fastq.gz \
	${in_dir}/${fastq_pre}_R2_001.fastq.gz \
	${out_dir}/${fastq_post}_trim_fw_paired.fastq.gz \
	${out_dir}/${fastq_post}_trim_fw_unpaired.fastq.gz \
	${out_dir}/${fastq_post}_trim_rev_paired.fastq.gz \
	${out_dir}/${fastq_post}_trim_rev_unpaired.fastq.gz \
	ILLUMINACLIP:NexteraPE-PE.fa:2:30:10:8:TRUE \
	LEADING:3 \
	TRAILING:3 \
	SLIDINGWINDOW:4:15 \
	MINLEN:20	
}

for (sample in "${samples[@]}"); do
	trim $sample
done
