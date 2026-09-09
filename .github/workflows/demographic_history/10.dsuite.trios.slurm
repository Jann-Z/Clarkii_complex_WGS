#!/bin/bash

#SBATCH --job-name=Dsuite
#SBATCH --partition=compute
#SBATCH -c 8
#SBATCH --mem=50G
#SBATCH --output=outscripts/sel_6samples.%j.out
#SBATCH --error=outscripts/sel_6samples.%j.err
#SBATCH --time=12:00:00
#SBATCH --array=1-24

VCFDIR=chromosomes


/apps/Dsuite/Build/Dsuite Dtrios -o dsuite/trios/chr${SLURM_ARRAY_TASK_ID}.trio \
$VCFDIR/chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf.vcf.gz AllSamplesPopOut.txt
