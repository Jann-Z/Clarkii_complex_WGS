#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 2:00:00
#SBATCH --mem=20G
#SBATCH -c 2
#SBATCH --job-name=SortSam
#SBATCH --output=outscripts/SortSam1_%a.out
#SBATCH --error=outscripts/SortSam1_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesExtra.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-04_bam}                   # Name of the directory with the input mapping files (should be in workindir)
outdir=${4-05_sort}            # Directory containing variant files
##############################


############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $outdir
fi

############################################################
# Check settings
echo "Using following arguments:

List of Samples:        "$SampleList"
Working directory:      "$workindir"
Mapping Files directory (if relative path, from "$workindir") : "$inputfileDir"
Out directory:      "$outdir"

If settings are wrong, please look at instructions and arguments to pass
"

####################
# LOAD MODULES
####################
ml picard/2.7.0

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
mkdir -p ${workindir}/04_sort.dup

picard SortSam \
                I=$inputfileDir/$sample.bam \
                O=${outdir}/$sample.sorted.bam \
                SORT_ORDER=coordinate
####################
# END
####################
echo "The script for sample "$sample" has finished"
