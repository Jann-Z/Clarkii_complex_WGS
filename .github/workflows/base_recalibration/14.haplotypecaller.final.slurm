#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=40G
#SBATCH -c 10
#SBATCH --job-name=Haplotypecaller
#SBATCH --output=outscripts/HaplotypeCaller.calibrated__first%a.out
#SBATCH --error=outscripts/HaplotypeCaller.calibrated_first_%a.err

### Argument to pass:
SampleList=${1-Samples.txt}                  # Name of the file with sample names. Default: Samples.txt
workindir=${2-.}                                # Working directory. Default: Current Directory
inputfileDir=${3-15_calibrated_bam_final}                   # Name of the directory with calibrated bams


## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir
fi


### LOAD MODULES
ml java-jdk/17

### Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

### Running haplotype caller

mkdir -p ${workindir}/16_called_variants_final


/apps/gatk-4.4.0.0/gatk --java-options "-Xmx4g" HaplotypeCaller \
      -R ${workindir}/Aclarkii_genome.fasta \
      -I ${workindir}/$inputfileDir/$sample.calibrated.final.bam \
      -O ${workindir}/16_called_variants_final/$sample.calibrated_final.g.vcf.gz \
      -ERC GVCF
