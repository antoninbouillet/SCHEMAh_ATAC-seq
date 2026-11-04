#Traitement des données séquençage ATAC-seq

sources :
	- https://nf-co.re/atacseq/2.1.2/
	- https://www.encodeproject.org/atac-seq/

##1. contrôle qualité avec FastQC (fastqc_pre.sh)

##2. nettoyage & retrait des adapters avec Trimmomatic (trim.sh)

	/!\ seulement 25 % des reads sont appariés 
	
	(d'après https://www.biostars.org/p/418363/)
	
	
	> " Trimmomatic's default behaviour is to drop the reverse reads when it trims adapters, so you get forward reads only surviving as a result.
	> The reasoning behind this is that when you read into the adapter sequences it means that the insert is shorter than one of the reads, so the 
	> reverse read doesn't add any extra information, it is just the reverse complement of the forward read." 
	
	les reads non appariés correspondent aux reads avec adapters.
		- régler keepBothReads dans ILLUMINACLIP à TRUE pour conserver le read antisens si problème avec bowtie2 (ok)
	

##3. second contrôle qualité (fastqc_post.sh)
	
	-reads appariés ~150pb
	- reads non appariés < 150 pb : pic à ~40pb :
		- ajuster MINLEN à 20pb dans Trimmomatic pour conserver les reads courts

	Les fragments transposés sont majoritairement < 150 pb de long.
	
	manuel trimmomatic : http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf
		
	>"Although adapter and other technical sequences can potentially occur in any location within
	>reads, by far the most common cause of adapter contamination is sequencing of a DNA
	>fragment which is shorter than the read length. In this scenario, the beginning of the read
	>contains valid data, but when the end of the fragment is reached, the sequencer continues to
	>„read-through‟ into the adapter. This results in a partial or full adapter sequence towards the 3‟
	>end of the read. While a full adapter sequence can be identified relatively easily, reliably
	>identifying a short partial adapter sequence is inherently difficult."
	
##4. alignement avec bowtie2 (alignement.sh)

	5a1 : ~ 79.5 % mapped = 151M / 190M reads
	5a2 : ~ 78.4 % mapped = 169M / 216M reads
	5a3 : ~ 79.2 % mapped = 89M / 113M reads
	
	C1 : ~ 79.3 % mapped = 132M / 167M reads
	C2 : ~ 79.6 % mapped = 159M / 200M reads
	C3 : ~ 78.8 % mapped = 127M / 161M reads
	
	dg1 : ~ 58 % mapped = 128M / 217M reads
	dg2 : ~ 65 % mapped = 35k / 53k reads


##5. annotation des reads dupliqués avec samtools (markdup.sh)

	manuel : https://www.htslib.org/doc/samtools-markdup.html
	ressources : 
	https://www.htslib.org/algorithms/duplicate.html
	https://www.biostars.org/p/351948/
	https://www.biostars.org/p/343260/
	
	
note : le génome mitochondrial a été retiré de l'assemblage

##6. filtre
	
	Retrait des reads: 
	(avec samtools - flag final : 1284)
	- dupliqués (flag 4)
	- non alignés (flag 1024)
	- correspondant à des alignements secondaires (flag 256)
	
	(avec bamtools, en utilisant les paramètres 'bamtools_filter_pe.json' obtenus sur https://nf-co.re/atacseq/2.1.2/)
	- ayant une taille d' insert de > 2kb
	- à + de 4 mismatches
	- ayant des extrémités 3' et 5' non alignées (soft clipped, cf. https://davetang.org/wiki/tiki-index.php?page=SAM#Clipped_alignment)
	
	((+ retrait des reads orphelins avec pysam, en utilisant le script 'bampe_rm_orphan.py' de https://nf-co.re/atacseq/2.1.2/))
		- la majorité des reads sont orphelins (cf. étape 2) -> ce filtre ne sera pas utilisé
	
	- fichier final = $SAMPLE_filtered.bam

##7. conversion en BigWig & enrichissement au niveau des gènes
	
	- normalisation des données en nb. reads par bin / million de reads total (CPM)
	
	PCA : regroupement de ~ 5a1/C1 ; 5a2/C3 ; 5a3/C2 (dg1 isolé)
		-> regroupement par individu ?
		
	- données non normalisées : pas de regroupement clair
	
	- enrichissement des gènes asymétrique entre TSS et TES (contrairement à l'analyse précédente) : pic d'enrichissement au TSS
	
##8. décodage des régions ouvertes avec hmmratac

	manuel : https://macs3-project.github.io/MACS/docs/hmmratac.html
	
	- test avec les paramètres précédents (-c 2 -l 10 -u 20 --hmm-type poisson ): 
		-> beaucoup de variabilité entre échantillons, capture de trop de bruit de fond (cf. cutoff analysis)
	
	- augmentation du prescan_cutoff (-c) à 6, du upper cutoff (-u) à 30 + modèle Gauss (défaut):
		-> 5a1 : bcp trop de bases & peaks, 5a2 : trop peu. beaucoup de variabilité dans la longueur des peaks.
		
	- test des paramètres proches du défaut (-c 1.2 -l 5 -u 20) - -l 5 car la majorité des peaks semblent avoir un score assez faible.
			- 
		-> idem que précédemment.. Kassambara A (2023)
		
	/!\ hmmratac n'utilise pas les reads, mais les fragments reconstitués à partir des paires de reads.
		
		-> pb : les paires de reads ne représentent que 6 à 20 % des reads totaux (cf. report multiqc bam_filtered)
		
		-> 2 solutions : 
		
			1. conserver les paires avec Trimmomatic, même si celles-ci sont redondantes (cf. #2) : 
		
				Cela pourrait biaiser le décodage en ajoutant de très nombreux fragments de la taille d'un read ?
				cependant, les reads non appariés correspondent à des fragments de < 150bp, où read = fragment (si l'adapter a bien été retiré).
				donc ok
	
		
			2. utiliser macs3 callpeak pour prendre en compte les reads non appariés.
