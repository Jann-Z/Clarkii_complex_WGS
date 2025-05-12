#!/bin/bash

#SBATCH --job-name=Filtering
#SBATCH --partition=compute
#SBATCH -c 8
#SBATCH --mem=150G
#SBATCH --output=outscripts/Filter_calibrated.%j.out
#SBATCH --error=outscripts/Filter_calibrated.%j.err
#SBATCH --time=32:00:00

#### The script is used to filter the variants ####
# We tried two kinds of filtering methods with some different thresholds. Comment out one of them if you just want to use one method.

###########################
# Arguments to pass:
workindir=.                                     # Working directory. Default: Current directory
ReferenceGenome=Aclarkii_genome.fasta
inputfileDir=16_genotype.output.calibrated                      # Name of the directory with the merged gVCF files each sample (should be in workindir). Default: 3C_CallingOutput
outputfileDir=17_filtered.calibrated            # Name of the directory with a database workspace. Default: 4B_FilteredCalling

############################################################


# Check settings
echo "Using following arguments:

Working directory:      "$workindir"
Input directory (if relative path, from "$workindir") : "$inputfileDir"
Output directory: "$outputfileDir


echo "
If settings are wrong, please look at instructions and arguments to pass

"

####################
# LOAD MODULES
####################

module load vcftools/0.1.16

####################
# BEGINNING OF SCRIPT
####################
cd $workindir

######################
# Follow the speciation genomics tutorial (SG)
######################
#mkdir -p 4B_FilteredCalling_uncalibrated/SpeciationGenomicsTutorial

# Set the variables as thresholds
MAF=0.01
NONMISSING=0.8
QUAL=30
MIN_DEPTH=8
MAX_DEPTH=32

# Filter the variants
echo "Apply filters to the SNPs with these thresholds:
-- MAF = 0.01
-- NONMISSING = 0.8
-- QUAL = 30
-- MIN_DEPTH = 8
-- MAX_DEPTH = 32

Please check the thresholds!

-------------

Start to filter using VcfTools"

vcftools --gzvcf $inputfileDir"/snps.worldwide.genotyped.calibrated.vcf.gz" \
                --remove-indels \
                --maf $MAF \
                --max-missing $NONMISSING \
                --minQ $QUAL \
                --minDP $MIN_DEPTH \
                --maxDP $MAX_DEPTH \
                --recode --stdout | gzip -c > $outputfileDir"/snps.worldwide.calibrated_SNP.filtered.maf001MD8NM08.vcf.gz"


####################
# END
####################


echo "Script has finished!"

