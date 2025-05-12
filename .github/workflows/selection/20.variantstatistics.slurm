#!/bin/bash
#SBATCH --job-name=VarStats-S67
#SBATCH --partition=compute
#SBATCH -c 8
#SBATCH --mem=30G
#SBATCH --output=outscripts/VarStats-S67_uncalibrated.out
#SBATCH --error=outscripts/VarStats-S67_uncalibrated.err
#SBATCH --time=5:00:00

#### The script is used to generate statistics of variants ####
# One should firstly calculate the statistics and then set up thresholds to filter according to the statistics.

###########################
# Arguments to pass:
workindir=.                                     # Working directory. Default: Current directory
inputfileDir=16_genotype.output.calibrated                      # Name of the directory with the variant callset (should be in workindir). Default: 4B_FilteredCalling
inputfile=snps.worldwide.genotyped.calibrated.vcf.gz    # Name of file that is going to be calculated
outputfileDir=20_calibrated_variants_stats      # Name of the directory with statistics files (should be in workindir). Default: 4A_CallingStatistics
outputprefix=snps.worldwide             # Prefix of the output files
############################################################

####################
# LOAD MODULES
####################

module load vcftools/0.1.16

####################
# BEGINNING OF SCRIPT
####################
cd $workindir

# Calculate allele frequency
vcftools --gzvcf $inputfileDir"/"$inputfile --freq2 --out $outputfileDir"/"$outputprefix --max-alleles 2
echo "Done calculating allele frequency"

# Calculate mean depth per individual
vcftools --gzvcf $inputfileDir"/"$inputfile --depth --out $outputfileDir"/"$outputprefix
echo "Done calculating mean depth for each sample"

# Calculate mean depth per site
vcftools --gzvcf $inputfileDir"/"$inputfile --site-mean-depth --out $outputfileDir"/"$outputprefix
echo "Done calculating mean depth for each SNP"

# Calculate site quality
vcftools --gzvcf $inputfileDir"/"$inputfile --site-quality --out $outputfileDir"/"$outputprefix
echo "Done calculating site quality"

# Calculate proportion of missing data per individual
vcftools --gzvcf $inputfileDir"/"$inputfile --missing-indv --out $outputfileDir"/"$outputprefix
echo "Done calculating the proportion of missing data for each sample"
# Calculate proportion of missing data per site
vcftools --gzvcf $inputfileDir"/"$inputfile --missing-site --out $outputfileDir"/"$outputprefix
echo "Done calculating the proportion of missing data for each SNP"

# Calculate heterozygosity and inbreeding coefficient per individual
vcftools --gzvcf $inputfileDir"/"$inputfile --het --out $outputfileDir"/"$outputprefix
echo "Done calculating heterozygosity and inbreeding coefficient for each sample"


####################
# END
####################


echo "The script has finished!"
(END)

