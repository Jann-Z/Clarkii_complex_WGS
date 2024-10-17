#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 28:00:00
#SBATCH --mem=50G
#SBATCH -c 2
#SBATCH --job-name=sam2bam
#SBATCH --output=outscripts/sam2bam_%a.out
#SBATCH --error=outscripts/sam2bam_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesExtra.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-/bucket/LaudetU/Jann/Salamin_sequences/fastq}                   # Name of the directory with the input mapping files (should be in workindir)
##############################

############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir
fi

############################################################
# Check settings
echo "Using following arguments:

List of Samples:        "$SampleList"
Working directory:      "$workindir"
Mapping Files directory (if relative path, from "$workindir") : "$inputfileDir"

If settings are wrong, please look at instructions and arguments to pass
"
####################
# LOAD MODULES
####################
module load samtools/1.12

####################
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

####################
# Convert sam to bam
####################

samtools view -bo 04_bam/${sample}.bam 03_sam/${sample}.sam

####################
# END OF SCRIPT
####################
