#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 128:00:00
#SBATCH --mem=40G
#SBATCH -c 6
#SBATCH --job-name=Hap.call.cali
#SBATCH --output=outscripts/HaplotypeCaller.calibrated_%a.out
#SBATCH --error=outscripts/HaplotypeCaller.calibrated_%a.err
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesWorldwide2.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-13_calibrated_bam}                   # Name of the directory with the input mapping files (should be in workindir)
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
ml java-jdk/17


# BEGINNING OF SCRIPT
####################

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

####################
# Running haplotype caller
####################
mkdir -p ${workindir}/14_called.variants.calibrated

/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk --java-options "-Xmx4g" HaplotypeCaller \
      -R ${workindir}/Aclarkii_genome.fasta \
      -I $inputfileDir/$sample.calibrated.bam \
      -O ${workindir}/14_called.variants.calibrated/$sample.calibrated_variants.g.vcf.gz \
      -ERC GVCF

####################
# END
####################
