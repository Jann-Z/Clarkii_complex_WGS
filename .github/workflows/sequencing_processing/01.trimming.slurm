#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=50G
#SBATCH -c 2
#SBATCH --job-name=cutadapt


##############################
# Argument to pass:
###########################3##
SampleList=${1-AllSamples.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-./01_fastq}                   # Name of the directory with the input mapping files (should be in workindir)
outputfileDir=${4-./02_trimmed}
##############################

############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline%56 $0 $SampleList $workindir $inputfileDir $outputfileDir
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
ml bioinfo-ugrp-modules  DebianMed/12.0
DIR=/apps/free81/Trimmomatic/0.39/lib

####################
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory


####################
# Trimmomatic
####################

java -jar $DIR/trimmomatic-0.39.jar PE $inputfileDir/${sample}_1.fastq.gz $inputfileDir/${sample}_2.fastq.gz \
        $outputfileDir/${sample}_1_trimmed_paired.fastq.gz \
        $outputfileDir/${sample}_1_trimmed_unpaired.fastq.gz \
        $outputfileDir/${sample}_2_trimmed_paired.fastq.gz \
        $outputfileDir/${sample}_2_trimmed_unpaired.fastq.gz \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

####################
# END OF SCRIPT
####################

