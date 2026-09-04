



angsd -GL 1 -out chromosomes/chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf -nThreads 20 \
-ref Aclarkii_genome.fasta -bam chr${SLURM_ARRAY_TASK_ID}.bamlist.txt -minMapQ 30 -minQ 20 -baq 1 -doMajorMinor 1 -skipTriallelic 1 -doGeno 32 -doPost 1 -doBcf 1





#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=200G
#SBATCH -c 50
#SBATCH --job-name=bcf.concat
#SBATCH --output=outscripts/bcf.concat.%j.out
#SBATCH --error=outscripts/bcf.concat.%j.err
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jann.zwahlen@oist.jp
ml bioinfo-ugrp-modules DebianMed/13.0-1
ml bcftools

bcftools concat \
    -f filelist.txt \
    -Oz \
    -o all.chr.allsamples.vcf.gz

bcftools index -t all.chr.allsamples.vcf.gz


