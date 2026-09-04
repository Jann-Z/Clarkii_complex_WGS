#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 128:00:00
#SBATCH --mem=100G
#SBATCH -c 64
#SBATCH --job-name=combine.GVCFs.Worldwide
#SBATCH --output=combine.GVCFs.worldwide.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Jann.zwahlen@oist.jp

# Set the path to the directory containing your raw VCF files
VCF_DIR=/flash/LaudetU/Jann/Salamin_sequences/14_called.variants.calibrated_snps
#  Set the path to the output directory
OUTPUT_DIR=/flash/LaudetU/Jann/Salamin_sequences/15_combined.variants.calibrated

# Set the output file name
OUTPUT_FILE="$OUTPUT_DIR/snps.worldwide.combined.calibrated.g.vcf.gz"

# Set the reference
REFERENCE=/flash/LaudetU/Jann/WGS/Aclarkii_genome.fasta
# Initialize the GATK CombineGVCFs command
GATK_COMMAND="CombineGVCFs -R $REFERENCE -O $OUTPUT_FILE"

ml load java-jdk/17

# Loop through the files and add each one to the GATK command
for file in $VCF_DIR/*.snps_calibrated_variants.g.vcf.gz; do
    GATK_COMMAND+=" -V $file"
done

# Print the command for debugging
echo "Running command: $GATK_COMMAND"

# Run the GATK CombineGVCFs command
/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk $GATK_COMMAND
