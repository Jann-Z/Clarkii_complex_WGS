#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 128:00:00
#SBATCH --mem=20G
#SBATCH -c 2  #run time not reduced with more than 2cpus
#SBATCH --job-name=BaseRecalibration
#SBATCH --output=base.recalibration_%a.out
#SBATCH --error=base.recalibration_%a.err


### Argument:
SampleList=${1-Samples.txt}                  # Name of the file with sample names. Default: Samples.txt
workindir=${2-.}                                        # Working directory. Default: Current Directory
inputfileDir=${3-07_sort.dup.rg}                       # Name of the directory with bam files
variantdir=${4-10_genotyped.variants}

### Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $variantdir
fi

### LOAD MODULES
ml load java-jdk/17

# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Change to working directory
cd $workindir

### Running base recalibrator
/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk BaseRecalibrator \
                -I $inputfileDir/$sample.sorted.dup.rg.bam \
                -R Aclarkii_genome.fasta \
                --known-sites ${variantdir}/all.snps.filtered.1st.vcf.gz \
                -O ${variantdir}/$sample.dup.sorted.rg.bqsr.report



