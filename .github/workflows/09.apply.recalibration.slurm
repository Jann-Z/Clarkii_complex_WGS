#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=20G
#SBATCH -c 2  # Run time not reduced with more than 2 CPUs
#SBATCH --job-name=applyBQSR2nd
#SBATCH --output=outscripts/newApplyBQSR2nd_%a.out
#SBATCH --error=outscripts/newApplyBQSR2nd_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesWorldwide2.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-/bucket/LaudetU/Jann/Salamin_sequences/07_sort.dup.rg}                   # Name of the directory with the input mapping files (should be in workindir)
variantdir=${4-12_calibrated.variants}            # Directory containing variant files
##############################


############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $variantdir
fi

############################################################
# Check settings
echo "Using following arguments:

List of Samples:        "$SampleList"
Working directory:      "$workindir"
Mapping Files directory (if relative path, from "$workindir") : "$inputfileDir"
Variant directory:      "$variantdir"

If settings are wrong, please look at instructions and arguments to pass
"

####################
# LOAD MODULES
####################
ml java-jdk/17

####################
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

####################
# Running base recalibrator
####################
mkdir -p ${workindir}/13_calibrated_bam

/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk ApplyBQSR \
                -I $inputfileDir/$sample.sorted.dup.rg.bam \
                -R ${workindir}/Aclarkii_genome.fasta \
                --bqsr-recal-file ${variantdir}/$sample.bqsr.report \
                -O ${workindir}/13_calibrated_bam/$sample.calibrated.bam

####################
# END
####################

echo "The script for sample "$sample" has finished"
