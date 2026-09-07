#!/bin/bash

#SBATCH --job-name=Filtering
#SBATCH --partition=compute
#SBATCH -c 20
#SBATCH --mem=100G
#SBATCH --output=outscripts/Filter_uncalibrated_first.out
#SBATCH --error=outscripts/Filter_uncalibrated_first.err
#SBATCH --time=12:00:00

### LOAD MODULES
ml java-jdk/17

ReferenceGenome=Aclarkii_genome.fasta
Dir=10.genotyped_variants                   
                  
######################
# Follow the filtering steps recommended by GATK
######################
# mkdir -p 4B_FilteredCalling/GATK_RecStandards


### Select SNPs only


/apps/gatk-4.4.0.0/gatk SelectVariants \
        -R Aclarkii_genome.fasta \
        -V $Dir/all.genotyped.vcf.gz \
        --select-type-to-include SNP \
        --ignore-non-ref-in-types \
        -O $Dir/all.snps.vcf.gz

### filter SNPs

/apps/gatk-4.4.0.0/gatk VariantFiltration \
     -V $Dir"/all.snps.vcf.gz" \
     -filter "QD < 2.0" --filter-name "QD2" \
     -filter "SOR > 3.0" --filter-name "SOR3" \
     -filter "FS > 60.0" --filter-name "FS60" \
     -filter "MQ < 40.0" --filter-name "MQ40" \
     -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
     -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
     -O $Dir"/all.snps.with.filter.1st.vcf.gz"


# Subset SNPs that pass all the filters
/apps/gatk-4.4.0.0/gatk SelectVariants \
        --exclude-filtered \
        -V $outputfileDir"/all.snps.with.filter.1st.vcf.gz" \
        -O $outputfileDir"/all.snps.filtered.1st.vcf.gz"













#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 12:00:00
#SBATCH --mem=50G
#SBATCH -c 20  #run time not reduced with more than 2cpus
#SBATCH --job-name=select_snps
#SBATCH --output=select_snps.2.out



ReferenceGenome=Aclarkii_genome.fasta
Dir=10.genotyped_variants

ml java-jdk/17

/apps/gatk-4.4.0.0/gatk SelectVariants \
        -R Aclarkii_genome.fasta \
        -V $Dir/all.genotyped.vcf.gz \
        --select-type-to-include SNP \
        --ignore-non-ref-in-types \
        -O $outputfileDir/all.snps.vcf.gz

