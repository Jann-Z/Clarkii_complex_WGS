#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4:00:00
#SBATCH --mem=5G
#SBATCH -c 4
#SBATCH --mail-user=jann.zwahlen@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --job-name=phasing
#SBATCH --output=phasing.%A_%a.out
#SBATCH --array=2-24

# Load required modules
ml bioinfo-ugrp-modules DebianMed/12.0
ml bcftools/1.16-1

# Define variables
VCF_DIR=/flash/LaudetU/Jann/WGS/vcf_chromosomes
VCF=${VCF_DIR}/filtered.chr${SLURM_ARRAY_TASK_ID}.vcf.gz
SHAPEIT=/apps/unit/LaudetU/shapeit_v2.17/bin/shapeit

# Extract the chromosome identifier
CHR="chr${SLURM_ARRAY_TASK_ID}"

# Define the output prefix
OUTPUT="wgs.${CHR}_phased"

# Run ShapeIT for phasing
$SHAPEIT --input-vcf $VCF \
 -O $OUTPUT \
 --force --window 0.5 -T 4

# Convert the phased haplotypes to VCF
$SHAPEIT -convert \
 --input-haps ${OUTPUT} \
 --output-vcf ${OUTPUT}.vcf

# Compress and index the resulting VCF
bgzip ${OUTPUT}.vcf
bcftools index ${OUTPUT}.vcf.gz

# Subset the VCF for different groups
VCF_NEW=${OUTPUT}.vcf.gz

bcftools view -S ogasawara -O z -o ogasawara_${CHR}.vcf.gz $VCF_NEW
bcftools view -S mainland -O z -o mainland_${CHR}.vcf.gz $VCF_NEW
bcftools view -S ryukyu -O z -o ryukyu_${CHR}.vcf.gz $VCF_NEW
bcftools view -S guam -O z -o guam_${CHR}.vcf.gz $VCF_NEW

# Index the subset VCFs
bcftools index ogasawara_${CHR}.vcf.gz
bcftools index mainland_${CHR}.vcf.gz
bcftools index ryukyu_${CHR}.vcf.gz
bcftools index guam_${CHR}.vcf.gz
