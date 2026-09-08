#!/bin/bash

#SBATCH --job-name=Filtering
#SBATCH --partition=compute
#SBATCH -c 20
#SBATCH --mem=100G
#SBATCH --output=logs/Filter_angsd_allchr.%j.out
#SBATCH --error=logs/Filter_angsd_allchr.%j.err
#SBATCH --time=24:00:00

ml vcftools
ml bcftools

###filter main VCF file
vcftools --gzvcf allchr.allsamples.vcf.gz --mac 2 --max-missing 0.9 \
--recode --stdout | gzip -c > allchr.allsamples.filter.vcf.gz

###remove outgroup
bcftools view -s ^SRR31951262 allchr.allsamples.filter.vcf.gz -Oz -o allchr.allsamples.filter.nochry.vcf.gz
