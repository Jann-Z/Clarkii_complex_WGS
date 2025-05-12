#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 72:00:00
#SBATCH --mem=500G
#SBATCH -c 20  #run time not reduced with more than 2cpus
#SBATCH --job-name=easySFS.preview
#SBATCH --output=easySFS.preview_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jann.zwahlen@oist.jp

#VCF=/flash/LaudetU/Jann/Salamin_sequences/11_filtered.uncalibrated/for.sfs.uncalibrated.vcf.gz

VCF=/flash/LaudetU/Jann/Salamin_sequences/10_genotype.output/worldwide.genotyped.uncalibrated.vcf.gz
easySFS=/apps/unit/LaudetU/easySFS/easySFS.py

$easySFS -i $VCF -p pop_file -f -v --preview
