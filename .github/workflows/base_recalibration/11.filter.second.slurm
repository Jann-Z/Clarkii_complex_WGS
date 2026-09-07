#!/bin/bash

#SBATCH --job-name=Filtering
#SBATCH --partition=compute
#SBATCH -c 20
#SBATCH --mem=100G
#SBATCH --output=outscripts/Filter_calibrated_second.out
#SBATCH --error=outscripts/Filter_calibrated_second.err
#SBATCH --time=12:00:00
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=Jann.zwahlen@oist.jp

### Arguments to pass:
workindir=.                                                   #  Working directory. 
ReferenceGenome=Aclarkii_genome.fasta
inputfileDir=13_combined.calibrated.first                     # Name of the directory with genotyped second file
outputfileDir=14_filtered.variants.second              # Name of the directory with a database workspace.


### Load modules
ml java-jdk/17

###script
cd $workindir

### Select SNPs only
/apps/gatk-4.4.0.0/gatk SelectVariants \
        -R Aclarkii_genome.fasta \
        -V $inputfileDir/all.genotyped.first.vcf.gz \
        --select-type-to-include SNP \
        --ignore-non-ref-in-types \
        -O $outputfileDir/all.genotyped.first.snps.vcf.gz

### annotate filters
/apps/gatk-4.4.0.0/gatk VariantFiltration \
     -V $outputfileDir"/all.snps.second.vcf.gz" \
     -filter "QD < 2.0" --filter-name "QD2" \
     -filter "SOR > 3.0" --filter-name "SOR3" \
     -filter "FS > 60.0" --filter-name "FS60" \
     -filter "MQ < 40.0" --filter-name "MQ40" \
     -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
     -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
     -O $outputfileDir"/all.snps.with.filter.2nd.vcf.gz"


### Subset SNPs that pass all the filters
/apps/gatk-4.4.0.0/gatk SelectVariants \
        --exclude-filtered \
        -V $outputfileDir"/all.snps.with.filter.2nd.vcf.gz" \
        -O $outputfileDir"/all.snps.filtered.2nd.vcf.gz"

