#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 32:00:00
#SBATCH --mem=20G
#SBATCH -c 2
#SBATCH --job-name=MarkDup
#SBATCH --output=outscripts/MarkDup_%a.out
#SBATCH --error=outscripts/MarkDup_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamples.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inDir=${3-05_sort}                   # Name of the directory with the input mapping files (should be in workindir)
outDir=${4-06_sort.dup} 
##############################


############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')


if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inDir $outDir
fi

############################################################
# Check settings
echo "Using following arguments:

List of Samples:        "$SampleList"
Working directory:      "$workindir"
Mapping Files directory (if relative path, from "$workindir") : "$inDir"
Outfile directory:	"$outDir"

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

picard MarkDuplicates \
                REMOVE_DUPLICATES=TRUE \
                I=$inDir/$sample.sorted.bam \
                O=$outDir/$sample.dup.sorted.bam \
                M=$outDir/$sample.dup.sorted.metrics.txt \
                CREATE_INDEX=true

####################
# END
####################
echo "The script for sample "$sample" has finished"
