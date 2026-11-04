#!/usr/bin/bash

source /home/bouille251/venv_MACS3/bin/activate
export TMPDIR=/home/bouille251/tmp/

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1)

bam_dir=${baseDir}/data/processing/bam_filtered
outdir=${baseDir}/data/processing/macs3/hmmratac

#définition des paramètres
prescan_cutoff="8"
lower_cutoff="15"
upper_cutoff="75"
hmmtype="poisson"
min_frag_p="0.05"
minlen="75"

#attention : carctères invisibles à la fin de l'extension '.bedpe'
#0000000   5   a   1   .   b   e   d   p   e 342 201 240

#Par réplicat

function hmmratac {

	echo -e "\n\n\n\n------------ $1 ------------\n\n\n\n"

	macs3 hmmratac \
	-i ${outdir}/${1}/${1}.bedpe⁠ \
	-n $1 \
	-f BEDPE \
	--binsize 10 \
	-c $prescan_cutoff \
	-l $lower_cutoff \
	-u $upper_cutoff \
	--min-frag-p $min_frag_p \
	--hmm-type $hmmtype \
	--decoding-steps 6000 \
	--minlen $minlen \
	--save-states \
	--outdir ${outdir}/"$1"
	
	Rscript ${outdir}/${1}/${1}_cutoff_analysis.R $prescan_cutoff $lower_cutoff $upper_cutoff

	echo -e "\n\n\n\n------------ done ------------\n\n\n\n"

}

for (sample in "${samples[@]}"); do
	hmmratac sample
done

Rscript ${outdir}/quick_analysis.R

wait

#Pool des réplicats

echo -e "\n\n\n\n------------ 5aza - pool ------------\n\n\n\n"

cd $outdir/5aza_pool

macs3 hmmratac \
-i 5a1.bedpe⁠ 5a2.bedpe⁠ 5a3.bedpe⁠ \
-f BEDPE \
-n 5aza \
--binsize 10 \
-c $prescan_cutoff \
-l $lower_cutoff \
-u $upper_cutoff \
--min-frag-p $min_frag_p \
--hmm-type $hmmtype \
--decoding-steps 6000 \
--minlen $minlen \
--save-states \
--outdir ${outdir}/5aza_pool

Rscript ${outdir}/5aza_pool/5aza_cutoff_analysis.R $prescan_cutoff $lower_cutoff $upper_cutoff

echo -e "\n\n\n\n------------ done ------------\n\n\n\n"

wait

echo -e "\n\n\n\n------------ control - pool ------------\n\n\n\n"

cd $outdir/control_pool

macs3 hmmratac \
-i C1.bedpe⁠ C2.bedpe⁠ C3.bedpe⁠ \
-f BEDPE \
-n control \
--binsize 10 \
-c $prescan_cutoff \
-l $lower_cutoff \
-u $upper_cutoff \
--min-frag-p $min_frag_p \
--hmm-type $hmmtype \
--decoding-steps 6000 \
--minlen $minlen \
--save-states \
--outdir ${outdir}/control_pool

Rscript ${outdir}/control_pool/control_cutoff_analysis.R $prescan_cutoff $lower_cutoff $upper_cutoff

echo -e "\n\n\n\n------------ done ------------\n\n\n\n"

Rscript ${outdir}/quick_analysis_pool.R
