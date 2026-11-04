#!/usr/bin/bash

#d'après https://www.biostars.org/p/351948/

#les reads dupliqués sont-t-ils alignés sur des régions spécifiques du génome ?
#normalement les duplicats s'alignent sur le génome mitochondrial, mais celui-ci a été retitré de l'assemblage.

#note: multiqc + samtools idxstats font presque la même opération...

chr_lengths="/mnt/MERSEA/Ref/Oyster_Genome/Sanger/GCF_963853765.1_xbMagGiga1.1_genomic.fna.fai"

baseDir=$(readlink -f $0 | xargs dirname | xargs dirname)
bam_dir=${baseDir}/data_processing/bam
bam_chr_out=${baseDir}/data_processing/bam/chromosomes

samtools view -b -H "${bam_dir}/dg2_markdup.bam" > bam_header.bam

echo bam_header


function map_chr {
 
  
  mapfile -t chr_names < <(cut -f1 -d$'\t' "$chr_lengths")

  for chr in "${chr_names[@]}"; do
  
	  chr_Reads=$(samtools idxstats $1 | grep "$chr" | cut -f 3)
	  totalReads=$(samtools idxstats $1 | awk '{SUM += $3} END {print SUM}')
	  echo "['$1', chr '$chr' content]:" $(bc <<< "scale=2;100*$chr_Reads/$totalReads")'%'
	  
	  #écriture d'un fichier bam / chromosome afin de vérifier leurs niveaux de dupliation individuels
	  samtools idxstats $1 | cut -f 1 | grep "$chr" | xargs samtools view -b $1 | \
	  
	  #changer le sample name pour créer des reports individualisés
	  samtools reheader "${bam_dir}/bam_header.bam" - > ${bam_chr_out}/"$2"/"$1"_"$chr".bam
  done

}; export -f map_chr


map_chr dg1_markdup.bam dg1
map_chr dg2_markdup.bam dg2

