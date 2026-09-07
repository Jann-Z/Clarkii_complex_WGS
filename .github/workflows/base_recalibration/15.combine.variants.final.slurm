#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=100G
#SBATCH -c 20
#SBATCH --job-name=combine.GVCFs.new
#SBATCH --output=combine.GVCFs.second.%j.out

# Set the path to the directory containing your raw VCF files
VCF_DIR="16_called_variants_final"

# Set the path to the output directory
OUTPUT_DIR="17_combined.calibrated.final"

# Set the output file name
OUTPUT_FILE="$OUTPUT_DIR/combined.calibrated.final.g.vcf.gz"

# Set the reference
REFERENCE=/Aclarkii_genome.fasta
# Initialize the GATK CombineGVCFs command
GATK_COMMAND="CombineGVCFs -R $REFERENCE -O $OUTPUT_FILE"

ml load java-jdk/17

# Loop through the files and add each one to the GATK command
for file in $VCF_DIR/*.calibrated_final.g.vcf.gz; do
    GATK_COMMAND+=" -V $file"
done

# Run the GATK CombineGVCFs command
/apps/gatk-4.4.0.0/gatk $GATK_COMMAND
