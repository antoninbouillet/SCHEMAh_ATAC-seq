#!/usr/bin/bash

#ajout de bamtools à PATH
PATH="${PATH:+${PATH}:}/home/bouille251/bamtools/usr/local/bin/"

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

dir_in=${baseDir}/data_processing/bam
dir_out=${baseDir}/data_processing/bam_filtered
bamtools_script=${baseDir}/bin/bamtools_filter_pe.json

: <<'EOF'
Retrait des reads: 
	(avec samtools)
	- dupliqués (flag 4)
	- non alignés (flag 1024)
	- correspondant à des alignements secondaires (flag 256)
	
	(avec bamtools, en utilisant 'bamtools_filter_pe.json' de https://nf-co.re/atacseq/2.1.2/)
	- ayant une taille d' insert de > 2kb
	- à + de 4 mismatches
	- ayant des extrémités 3' et 5' non alignées (cf. https://davetang.org/wiki/tiki-index.php?page=SAM#Clipped_alignment)
EOF

function filter {

	echo -e "\n------------ $1 ------------\n"	

	samtools view -@ 16 -b -F 1284 ${dir_in}/"$1"_markdup.bam | \
	bamtools filter -script $bamtools_script -out ${dir_out}/$1_filtered.bam
	
	wait
	
	samtools flagstat -@ 16 ${dir_out}/$1_filtered.bam > ${dir_out}/$1_flagstat.txt
	
	samtools stats -@ 16 ${dir_out}/$1_filtered.bam > ${dir_out}/$1_stats.txt
	
	samtools index -@ 16 ${dir_out}/$1_filtered.bam
	
	samtools idxstats -@ 16 ${dir_out}/$1_filtered.bam > ${dir_out}/$1_idxstats.txt
	
	echo -e '\n------------ done ------------\n'

	}

for (sample in "${samples[@]}"); do
	filter $sample
done
