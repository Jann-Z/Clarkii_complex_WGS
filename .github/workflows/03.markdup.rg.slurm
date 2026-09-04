#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 28:00:00
#SBATCH --mem=50G
#SBATCH -c 2
#SBATCH --job-name=dup.rg
#SBATCH --output=outscripts/dup.rg_%a.out
#SBATCH --error=outscripts/dup.rg_%a.err


##############################
# Argument to pass:
SampleList=${1-AllSamples.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-./05_bam.sort}                   # Name of the directory with the input mapping files (should be in workindir)
dupDir=${4-06_bam.dup}
rgDir=${5-07_bam.dup.rg}

##############################

############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline%56 $0 $SampleList $workindir $inputfileDir $dupDir $rgDir
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
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

mkdir -p "$dupDir" "$rgDir"
####################
# Mark duplicates
####################

java -jar /apps/free81/picard/2.7.0/bin/picard.jar MarkDuplicates \
            REMOVE_DUPLICATES=TRUE \
            I=$inputfileDir/${sample}.sorted.bam \
            O=${dupDir}/${sample}.sorted.dup.bam \
            METRICS_FILE=${dupDir}/${sample}.dup.metrics \
            CREATE_INDEX=true

####################
# Generate file with read name to later extract read group
####################

mkdir -p temp

samtools view $dupDir/${sample}.sorted.dup.bam | head -n 1 > "./temp/"$sample".header.txt"


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

picard AddOrReplaceReadGroups I=$dupDir/$sample.sorted.dup.bam \
O=$rgDir/$sample.sorted.dup.rg.bam \
RGID="$RGID" RGLB="$RGLB" RGPL="$RGPL" RGPU="$RGPU" RGSM="$RGSM"

####################
# END OF SCRIPT
####################
