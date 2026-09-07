#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 72:00:00
#SBATCH --mem=50G
#SBATCH -c 20  
#SBATCH --job-name=GenoType
#SBATCH --output=geno.type.uncalibrated.%j.out

ReferenceGenome=Aclarkii_genome.fasta

ml java-jdk/17

/apps/gatk-4.4.0.0/gatk --java-options "-Xmx4g" GenotypeGVCFs \
        -R $ReferenceGenome \
        -V 13_combined.calibrated.first/all.combined.calibrated.first.g.vcf.gz \
        -O 13_combined.calibrated.first/all.genotyped.first.vcf.gz
