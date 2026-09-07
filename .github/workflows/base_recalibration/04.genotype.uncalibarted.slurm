#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 72:00:00
#SBATCH --mem=50G
#SBATCH -c 20  #run time not reduced with more than 2cpus
#SBATCH --job-name=GenoType
#SBATCH --output=geno.type.uncalibrated%j.out


ReferenceGenome=Aclarkii_genome.fasta
outputfileDir=10.genotyped_variants

ml java-jdk/17

/apps/gatk-4.4.0.0/gatk --java-options "-Xmx4g" GenotypeGVCFs \
        -R $ReferenceGenome \
        -V ./09_variants.combined/all.combined.g.vcf.gz \
        -O $outputfileDir/all.genotyped.vcf.gz
