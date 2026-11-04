#!/usr/bin/bash

source /home/bouille251/venv_MACS3/bin/activate
export TMPDIR=/home/bouille251/tmp/

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

bam_dir=${baseDir}/data_processing/bam_filtered
outdir=${baseDir}/data_processing/macs3/callpeak


function callpeak {

	echo -e "\n\n\n\n------------ $1 ------------\n\n\n\n"

	macs3 callpeak \
	-t ${bam_dir}/${1}_filtered.bam \
	-n $1 \
	--keep-dup all \
	-g 563985000 \
	-B \
	-q 0.01 \
	--outdir $outdir/${1}

	echo -e "\n\n\n\n------------ done ------------\n\n\n\n"

}

# macs3 peak calling on individual replicates
:'
for (sample in "${samples[@]}"); do
	callpeak $sample
	
done

#Rscript ${outdir}/quick_analysis.R
'

# pooled replicates

wait

echo -e "\n\n\n\n------------ 5aza - pool ------------\n\n\n\n"

cd $bam_dir

macs3 callpeak \
-t 5a1_filtered.bam 5a2_filtered.bam 5a3_filtered.bam \
-n 5aza_pool \
--keep-dup all \
-g 563985000 \
-B \
-q 0.01 \
--outdir $outdir/5aza_pool

echo -e "\n\n\n\n------------ done ------------\n\n\n\n"

echo -e "\n\n\n\n------------ control - pool ------------\n\n\n\n"

cd $bam_dir

macs3 callpeak \
-t C1_filtered.bam C2_filtered.bam C3_filtered.bam \
-n control_pool \
--keep-dup all \
-g 563985000 \
-B \
-q 0.01 \
--outdir $outdir/control_pool

echo -e "\n\n\n\n------------ done ------------\n\n\n\n"
