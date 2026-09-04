#!/bin/bash
#SBATCH --job-name=angsd_chr
#SBATCH --partition=compute
#SBATCH -c 20
#SBATCH --mem=100G
#SBATCH --time=2-0
#SBATCH --output=logs/angsd_chr_%j_%a.out
#SBATCH --error=logs/angsd_chr_%j%a.err
#SBATCH --array=1-24

##############################
# Argument to pass:
SampleList=${1-AllSamples.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
outDir=${4-bam.chromosomes/}
##############################
############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $outDir
fi

### LOAD MODULES
ml samtools

### BEGINNING OF SCRIPT
# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "${sample}

# Change to working directory
cd $workindir

####################
# Separate .bam by chromosome.
####################
mkdir -p $outDir
chromosomes=($(samtools view -H "$sample" | grep "@SQ" | cut -f 2 | cut -d ':' -f 2))

for chromosome in ${chromosomes[@]}
do
    sample_name=$sample.calibrated.bam}
    output_bam=${chromosome}.$sample.bam
    samtools view -b sample.calibrated.bam $chromosome > ${outDir}/${chromosome}.$sample.bam
    samtools index ${outDir}/${chromosome}.$sample.bam
done



