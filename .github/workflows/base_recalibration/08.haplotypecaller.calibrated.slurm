#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 96:00:00
#SBATCH --mem=40G
#SBATCH -c 10
#SBATCH --job-name=Haplotypecaller
#SBATCH --output=outscripts/HaplotypeCaller.calibrated__first%a.out
#SBATCH --error=outscripts/HaplotypeCaller.calibrated_first_%a.err

### Argument to pass:
SampleList=${1-Samples.txt}                  # Name of the file with sample names. Default: Samples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-11_calibrated_first}                   # Name of the directory with the input mapping files (should be in workindir)

### Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir
fi

### LOAD MODULES
ml java-jdk/17

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

### Running base recalibrator
mkdir -p ${workindir}/12_called.variants.second

/apps/gatk-4.4.0.0/gatk --java-options "-Xmx4g" HaplotypeCaller \
      -R ${workindir}/Aclarkii_genome.fasta \
      -I ${workindir}/$inputfileDir/$sample.calibrated.first.bam \
      -O ${workindir}/12_called.variants.second/$sample.calibrated_variants.first.g.vcf.gz \
      -ERC GVCF
