source /home/bouille251/venv_MACS3/bin/activate
export TMPDIR=/home/bouille251/tmp/

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
samples=(5a1 5a2 5a3 C1 C2 C3 dg1 dg2)

bam_dir=${baseDir}/data_processing/bam_filtered
outdir=${baseDir}/data_processing/macs3

function bedpe {

	macs3 filterdup --keep-dup all -f BAMPE -i ${bam_dir}/$1_filtered.bam -o ${outdir}/hmmratac/$1/$1.bedpe⁠
	
	#pour utiliser le format bampe avec macs3 callpeak
	#${outdir}/hmmratac/$1/$1.bedpe⁠ ${outdir}/callpeak/$1
	
	}

for (sample in "${samples[@]}"); do
	bedpe $sample
done
