#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 2:00:00
#SBATCH --mem=20G
#SBATCH -c 4
#SBATCH --job-name=MarkDup
#SBATCH --output=outscripts/index1_%a.out
#SBATCH --error=outscripts/index1_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesExtra_redo.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-07_sort.dup.rg}                   # Name of the directory with the input mapping files (should be in workindir)
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
ml picard/2.7.0
ml samtools


# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

####################
# Readgroups
####################

####################
# Generate file with read name to later extract read group
####################
samtools index ${workindir}/$inputfileDir/$sample.sorted.dup.rg.bam


####################
# END
####################
