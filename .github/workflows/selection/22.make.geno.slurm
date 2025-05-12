#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 01:00:00
#SBATCH --mem=200G
#SBATCH -c 2
#SBATCH --job-name=process.vcf
#SBATCH --output=process.vcf.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

ml python
## download https://github.com/simonhmartin/genomics_general/ into ./python (or wherever)


python python/genomics_general/VCF_processing/parseVCF.py -i 17_filtered.calibrated/snps.worldwide.calibrated_SNP.filtered.maf001MD8NM08_5.vcf.gz --skipIndels -o 21_popgen/new.snps.worldwide.calibrated.geno.gz
