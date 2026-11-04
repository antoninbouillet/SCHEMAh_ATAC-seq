#!/usr/bin/bash

source /home/bouille251/venv_deeptools/bin/activate

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

bam_dir=${baseDir}/data_processing/bam_filtered
norm_dir=${baseDir}/data_processing/BigWig/normalized
raw_dir=${baseDir}/data_processing/BigWig/raw
genes="/mnt/MERSEA/Ref/Oyster_Genome/Sanger_free/genes.bed"

#normalisation par nb. reads par bin / million de reads total (CPM)
#taille de bin par défaut = 50pb

: '
si normalisation à un coverage de 1x, utiliser --effectiveGenomeSize 563954803
mais déconseillé selon (https://deeptools.readthedocs.io/en/latest/content/feature/effectiveGenomeSize.html)
car les multimapping reads ont été retirés
'

function bw {
	
	#BigWig normalisé
	bamCoverage -p 16 \
	--normalizeUsing CPM\
	--extendReads \
	-b ${bam_dir}/${1}_filtered.bam \
	-o ${norm_dir}/${1}_normalized.bw
	
	#BigWig non normalisé
	bamCoverage -p 16 \
	--extendReads \
	-b ${bam_dir}/${1}_filtered.bam \
	-o ${raw_dir}/${1}_raw.bw
	
}

for (sample in "${samples[@]}"); do
	bw $sample
done
