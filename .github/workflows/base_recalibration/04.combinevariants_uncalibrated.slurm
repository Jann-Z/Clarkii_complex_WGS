#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=100G
#SBATCH -c 20
#SBATCH --job-name=combine.GVCFs.new
#SBATCH --output=combine.GVCFs.new.%j.out

# Set the path to the directory containing your raw VCF files
VCF_DIR="08_called.variants"

# Set the path to the output directory
OUTPUT_DIR="09_called.variants_combined"

# Set the output file name
OUTPUT_FILE="$OUTPUT_DIR/all.combined.g.vcf.gz"

# Set the reference
REFERENCE=./Aclarkii_genome.fasta
# Initialize the GATK CombineGVCFs command
GATK_COMMAND="CombineGVCFs -R $REFERENCE -O $OUTPUT_FILE"

ml load java-jdk/17

# Loop through the files and add each one to the GATK command
for file in $VCF_DIR/*.uncalibrated_variants.g.vcf.gz; do
    GATK_COMMAND+=" -V $file"
done

# Print the command for debugging
echo "Running command: $GATK_COMMAND"

# Run the GATK CombineGVCFs command
/apps/gatk-4.4.0.0/gatk $GATK_COMMAND
