#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 96:00:00
#SBATCH --mem=8G
#SBATCH -c 2  # Run time not reduced with more than 2 CPUs
#SBATCH --job-name=applyBQSR2nd
#SBATCH --output=outscripts/ApplyBQSR2nd_%a.out
#SBATCH --error=outscripts/ApplyBQSR2nd_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-Samples.txt}                  # Name of the file with sample names. Default: Samples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-11_calibrated_first}                   # Name of the directory with the calibrated bams
variantdir=${4-14_filtered.variants.second}            # Directory containing filtered second file
##############################


############################################################
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

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

### Apply base recalibrator
####################
mkdir -p ${workindir}/15_calibrated_bam_final

/apps/gatk-4.4.0.0/gatk ApplyBQSR \
                -I $inputfileDir/$sample.calibrated.first.bam \
                -R ${workindir}/Aclarkii_genome.fasta \
                --bqsr-recal-file ${variantdir}/$sample.bqsr.2nd.report \
                -O ${workindir}/15_calibrated_bam_final/$sample.calibrated.final.bam
