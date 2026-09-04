#!/bin/bash
#SBATCH -p compute
#SBATCH -t 30:00:00
#SBATCH --mem=40G
#SBATCH -c 2


##############################
# Argument to pass:
SampleList=${1-AllSamples.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-./02_trimmed}                  # Name of the directory with the input mapping files (should be in workindir)
samDir=${4-03_sam}                              # Name of directory for sam files
bamDir=${5-04_bam}                              # Name of directory for bam files
##############################

############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline%42 $0 $SampleList $workindir $inputfileDir $samDir $bamDir
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
module load samtools/1.12
ml picard/2.7.0


####################
# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

mkdir -p "$samDir" "$bamDir" "bwalogs"
####################
# Align reads to reference
####################

bwa mem -M -t 2 \
Aclarkii_genome.fasta \
$inputfileDir/${sample}_1_trimmed_paired.fastq.gz $inputfileDir/${sample}_2_trimmed_paired.fastq.gz \
> bwalogs/bwa.${sample}.err \
> $samDir/${sample}.sam

####################
# Convert sam to bam
####################

samtools view -bo $bamDir/${sample}.bam $samDir/${sample}.sam

rm $samDir/${sample}.sam

mkdir -p ${workindir}/04_sort.dup


###################
# Sort sam
###################
mkdir -p 05_bam.sort

picard SortSam \
                I=$bamDir/$sample.bam \
                O=05_bam.sort/$sample.sorted.bam \
                SORT_ORDER=coordinate

####################
# Index BAM
####################

samtools index 05_bam.sort/$sample.sorted.bam

rm $bamDir/$sample.bam

####################
# END OF SCRIPT
####################
