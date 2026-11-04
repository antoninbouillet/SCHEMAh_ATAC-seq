#!/usr/bin/bash

#déclaration de TEMPDIR, sinon les fichiers temporaires sont écrits dans /tmp/, ce qui congestionne le root
export TMPDIR=/home/bouille251/tmp/

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1)

bamdir=${baseDir}/data_processing/bam

cd $bamdir

function markdup {

	echo -e "\n------------ $1 ------------\n"

	samtools collate -@ 16 -u -O $1_aligned.bam | \

	samtools fixmate -@ 16 -u -m - - | \

	samtools sort -@ 16 -u -O bam - | \

	samtools markdup -@ 16 -d 2500 - $1_markdup.bam
	
	wait
	
	samtools flagstat $1_markdup.bam > $1_stats.txt
	
	samtools index $1_markdup.bam
	
	samtools idxstats $1_markdup.bam > $1_idxstats.txt
	
	echo -e '\n------------ done ------------\n'
	
}

for (sample in "${samples[@]}"); do 
	markdup $sample
done
