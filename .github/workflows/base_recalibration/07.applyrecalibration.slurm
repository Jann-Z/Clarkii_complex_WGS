#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=8G
#SBATCH -c 2  
#SBATCH --job-name=apply_BaseRecalibration
#SBATCH --output=outscripts/ApplyBQSR_%a.out
#SBATCH --error=outscripts/ApplyBQSR_%a.err

### Argument to pass:
SampleList=${1-Samples.txt}                      # Name of the file with sample names. Default: Samples.txt
workindir=${2-.}                                 # Working directory. Default: Current Directory
inputfileDir=${3-07_sort.dup.rg}                   # Name of the directory with bam files
variantdir=${4-10_genotyped.variants}            # Directory containing BSQR

## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $variantdir
fi

### LOAD MODULES
ml java-jdk/17

### Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

### Print the name of the sample
echo "Working on sample:        "$sample

### Change to working directory
cd $workindir

### Apply base recalibration

mkdir -p ${workindir}/11_calibrated_first

/apps/gatk-4.4.0.0/gatk ApplyBQSR \
                -I $inputfileDir/$sample.sorted.dup.rg.bam \                
                -R ${workindir}/Aclarkii_genome.fasta \
                --bqsr-recal-file ${variantdir}/$sample.dup.sorted.rg.bqsr.report \
                -O ${workindir}/11_calibrated_first/$sample.calibrated.first.bam

