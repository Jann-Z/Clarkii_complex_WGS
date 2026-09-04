#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=100G
#SBATCH -c 20
#SBATCH --job-name=bcf.concat
#SBATCH --output=outscripts/angsd_chr.%j_%a.out
#SBATCH --error=outscripts/angsd_chr.%j_%a.err
#SBATCH --array=1-24

#first, create lists with all bam files for each chromosome (chr#.bamlist.txt), then run ANGSD

angsd -GL 1 -out chromosomes/chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf -nThreads 20 \
-ref Aclarkii_genome.fasta -bam chr${SLURM_ARRAY_TASK_ID}.bamlist.txt -minMapQ 30 -minQ 20 -baq 1 -doMajorMinor 1 -skipTriallelic 1 -doGeno 32 -doPost 1 -doBcf 1



