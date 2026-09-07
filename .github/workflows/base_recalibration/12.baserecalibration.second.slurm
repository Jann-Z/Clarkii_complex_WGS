#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 48:00:00
#SBATCH --mem=20G
#SBATCH -c 2  #run time not reduced with more than 2cpus
#SBATCH --job-name=BaseRecalibration2nd
#SBATCH --output=base.recalibration2nd_%a.out
#SBATCH --error=base.recalibration2nd_%a.err


### Argument to pass:
SampleList=${1-Samples.txt}                            # Name of the file with sample names. Default: Samples.txt
workindir=${2-.}                                        # Working directory. 
inputfileDir=${3-11_calibrated_first}                       # Name of the directory with calirated bams 
variantdir=${4-14_filtered.variants.second}      # Name of directory with filtered.second variants
outdir=${5-15_calibrated.variants.second}

### Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')

if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $variantdir $outdir
fi

### LOAD MODULES
ml load java-jdk/17

### Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir

### Running base recalibrator

/apps/gatk-4.4.0.0/gatk BaseRecalibrator \
                -I $inputfileDir/$sample.calibrated.first.bam \
                -R ${workindir}/Aclarkii_genome.fasta \
                --known-sites ${variantdir}/all.snps.filtered.2nd.vcf.gz \
                -O ${outdir}/$sample.bqsr.2nd.report


