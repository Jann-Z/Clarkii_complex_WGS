#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=20G
#SBATCH -c 2
#SBATCH --job-name=AddReplaceRG
#SBATCH --output=outscripts/AddReplaceRG_%a.out
#SBATCH --error=outscripts/AddReplaceRG_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesExtra_redo.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-06_sort.dup}                   # Name of the directory with the input mapping files (should be in workindir)
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
# Readgroups
####################

####################
# Generate file with read name to later extract read group
####################

mkdir -p temp

samtools view ${workindir}/$inputfileDir/$sample.sorted.dup.bam | head -n 1 > "./temp/"$sample".header.txt"

####################
# Get information for Readgroups
####################

string="$(cut -f1 "./temp/"$sample".header.txt")"
RGID="$(cut -d':' -f1-4 <<< $string)"
RGLB=$sample
RGPL="Illumina"
RGPU=$RGID"."$RGLB
RGSM=$sample

####################
# Add Read Groups
####################
mkdir -p 07_sort.dup.rg


picard AddOrReplaceReadGroups I=${workindir}/$inputfileDir/$sample.sorted.dup.bam \
O=${workindir}/07_sort.dup.rg/$sample.sorted.dup.rg.bam \
RGID="$RGID" RGLB="$RGLB" RGPL="$RGPL" RGPU="$RGPU" RGSM="$RGSM"


####################
# END
####################
