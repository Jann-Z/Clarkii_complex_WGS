#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=50G
#SBATCH -c 20  
#SBATCH --job-name=GenoType
#SBATCH --output=geno.type.uncalibrated.1.out


ReferenceGenome=Aclarkii_genome.fasta
Dir=17_combined.calibrated.final
ml java-jdk/17

/apps/gatk-4.4.0.0/gatk --java-options "-Xmx4g" GenotypeGVCFs \
        -R $ReferenceGenome \
        -V $Dir/combined.calibrated.final.g.vcf.gz \
        -O $Dir/genotyped.calibrated.vcf.gz
