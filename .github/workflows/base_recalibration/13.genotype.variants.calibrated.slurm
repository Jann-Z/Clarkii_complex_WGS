#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 128:00:00
#SBATCH --mem=200G
#SBATCH -c 20
#SBATCH --job-name=GenoType
#SBATCH --output=geno.type.calibrated_%j.out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=Jann.zwahlen@oist.jp


ReferenceGenome=Aclarkii_genome.fasta

ml java-jdk/17

/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk --java-options "-Xmx4g" GenotypeGVCFs \
        -R $ReferenceGenome \
        -V /flash/LaudetU/Jann/Salamin_sequences/15_combined.variants.calibrated/snps.worldwide.combined.calibrated.g.vcf.gz \
        -O 16_genotype.output.calibrated/snps.worldwide.genotyped.calibrated.vcf.gz
