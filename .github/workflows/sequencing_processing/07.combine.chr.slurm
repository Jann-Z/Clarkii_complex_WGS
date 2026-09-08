#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=200G
#SBATCH -c 20
#SBATCH --job-name=bcf.concat
#SBATCH --output=outscripts/bcf.concat.%j.out
#SBATCH --error=outscripts/bcf.concat.%j.err

ml bcftools

bcftools concat \
    -f filelist.txt \
    -Oz \
    -o all.chr.allsamples.vcf.gz

bcftools index -t all.chr.allsamples.vcf.gz

