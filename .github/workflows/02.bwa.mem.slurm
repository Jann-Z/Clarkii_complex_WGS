#!/bin/bash
#SBATCH -p compute
#SBATCH -t 30:00:00
#SBATCH --mem=40G
#SBATCH -c 2
#SBATCH --mail-user=jann.zwahlen@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --job-name=bwa_mem
#SBATCH --output=outscripts/cutadapt_%a.out
#SBATCH --error=outscripts/cutadapt_%a.err


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
ml bwa.icc/0.7.10

####################
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

####################
# Align reads to reference
####################

bwa mem -M -t 10 \
Aclarkii_genome.fasta \
02_cutQual/${sample}_trimmed_sickle_R1.fastq.gz 02_cutQual/${sample}_trimmed_sickle_R2.fastq.gz \
> bwalogs/bwa.${sample}.err \
> 03_sam/${sample}.sam

####################
# END OF SCRIPT
####################
