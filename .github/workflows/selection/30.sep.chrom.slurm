#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=5G
#SBATCH -c 2  #run time not reduced with more than 2cpus
#SBATCH --job-name=sep.chr
#SBATCH --output=sep.chr_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Jann.zwahlen@oist.jp
#SBATCH --array=1-24


ReferenceGenome=Aclarkii_genome.fasta
varDir=/flash/LaudetU/Jann/WGS/4B_FilteredCalling_uncalibrated/SpeciationGenomicsTutorial
outputfileDir=vcf_chromosomes2

ml java-jdk/17

/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk SelectVariants \
        -R Aclarkii_genome.fasta \
        -V $varDir/AllSamples.uncalibrated_mod5_SNP.SG.Filtered.vcf.gz \
        -L chr${SLURM_ARRAY_TASK_ID} \
        --ignore-non-ref-in-types \
        -O $outputfileDir/new.uncalibrated.chr${SLURM_ARRAY_TASK_ID}.vcf.gz

### keep only biallelic sites, keep only snps.

ml bioinfo-ugrp-modules DebianMed/12.0
ml bcftools/1.16-1
DIR=/bucket/LaudetU/Jann/WGS_Lausanne/vcf_chromosomes
bcftools view -m2 -M2 -v snps -O z -o filtered.chr${SLURM_ARRAY_TASK_ID}.vcf.gz $DIR/new.uncalibrated.chr${SLURM_ARRAY_TASK_ID}.vcf.gz

