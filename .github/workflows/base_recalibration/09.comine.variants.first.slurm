#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 72:00:00
#SBATCH --mem=100G
#SBATCH -c 64
#SBATCH --job-name=combine.GVCFs.new
#SBATCH --output=combine.GVCFs.second.%j.out

# Set the path to the directory containing your raw VCF files
VCF_DIR="12_called.variants.second"

# Set the path to the output directory
OUTPUT_DIR="13_combined.calibrated.first"

# Set the output file name
OUTPUT_FILE="$OUTPUT_DIR/all.combined.calibrated.first.g.vcf.gz"

# Set the reference
REFERENCE=Aclarkii_genome.fasta
# Initialize the GATK CombineGVCFs command
GATK_COMMAND="CombineGVCFs -R $REFERENCE -O $OUTPUT_FILE"

ml load java-jdk/17

# Loop through the files and add each one to the GATK command
for file in $VCF_DIR/*.calibrated_variants.first.g.vcf.gz; do
    GATK_COMMAND+=" -V $file"
done

# Run the GATK CombineGVCFs command
/apps/gatk-4.4.0.0/gatk $GATK_COMMAND
