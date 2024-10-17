#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=50G
#SBATCH -c 2
#SBATCH --job-name=cutadapt
#SBATCH --output=outscripts/cutadapt_%a.out
#SBATCH --error=outscripts/cutadapt_%a.err
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
ml bioinfo-ugrp-modules  DebianMed/12.0
ml cutadapt/4.2-1

####################
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory

inDir=/bucket/LaudetU/Jann/files
outDir=/flash/LaudetU/Jann/WGS/trimmed
ml bioinfo-ugrp-modules  DebianMed/12.0
ml cutadapt/4.2-1

####################
# CUT ADAPTERS
####################

cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
         -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
         -o 01_cutadapt/${sample}_trimmed_1.fastq.gz -p 01_cutadapt/${sample}_trimmed_2.fastq.gz \
         $inputfileDir/${sample}_1.fastq $inputfileDir/${sample}_2.fastq

####################
# DO FIRST QUALITY CHECK
####################

/apps/unit/LaudetU/sickle/sickle pe -g -f 01_cutadapt/${sample}_trimmed_1.fastq.gz -r 01_cutadapt/${sample}_trimmed_2.fastq.gz -t sanger \
-o 02_cutQual/${sample}_trimmed_sickle_R1.fastq.gz -p 02_cutQual/${sample}_trimmed_sickle_R2.fastq.gz \
-s 02_cutQual/${sample}_trimmed_sickle_singles.fastq.gz -q 30 -l 40


####################
# END OF SCRIPT
####################
