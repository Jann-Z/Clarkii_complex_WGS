#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 128:00:00
#SBATCH --mem=40G
#SBATCH -c 2
#SBATCH --job-name=MarkDup
#SBATCH --output=outscripts/HaplotypeCaller.uncalibrated_%a.out
#SBATCH --error=outscripts/HaplotypeCaller.uncalibrated_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jann.zwahlen@oist.jp

##############################
# Argument to pass:
SampleList=${1-AllSamplesWorldwide.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-/bucket/LaudetU/Jann/Salamin_sequences/07_sort.dup.rg}                   # Name of the directory with the input mapping files (should be in workindir)
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
# Running base recalibrator
####################
mkdir -p ${workindir}/08_called.variants

/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk --java-options "-Xmx4g" HaplotypeCaller \
      -R ${workindir}/Aclarkii_genome.fasta \
      -I $inputfileDir/$sample.sorted.dup.rg.bam \
      -O ${workindir}/08_called.variants/$sample.uncalibrated_variants.g.vcf.gz \
      -ERC GVCF

####################
# END
####################
