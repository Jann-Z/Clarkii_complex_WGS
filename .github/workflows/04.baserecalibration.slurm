#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=20G
#SBATCH -c 2
#SBATCH --job-name=SortSam
#SBATCH --output=outscriptsrecalibration_%a.out
#SBATCH --error=outscripts/recalibration_%a.err

### Argument to pass:
SampleList=${1-AllSamples.txt}                          # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                        # Working directory. Default: Current Directory
inputfileDir=${3-./07_bam.dup.rg}                       # Name of the directory with the input mapping files (should be in workindir).
variantdir=${4-./14_called.variants.second.combined}    
caldir=${5-./08_calibrated.variants}

### Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')


if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $variantdir $outdir
fi

### LOAD MODULES
ml load java-jdk/17

### BEGINNNING OF SCRIPT
# Get name of samples for array
sample=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SampleList)

# Print the name of the sample
echo "Working on sample:        "$sample

# Change to working directory
cd $workindir


### Running base recalibrator
/apps/gatk-4.4.0.0/gatk BaseRecalibrator \
                -I $inputfileDir/$sample.sorted.dup.rg.bam \
                -R ${workindir}/Aclarkii_genome.fasta \
                --known-sites ${variantdir}/all.snps.filtered.2nd.vcf.gz \
                -O ${caldir}/$sample.bqsr.report

### Running base recalibrator
mkdir -p ${workindir}/09_calibrated_bam

/apps/gatk-4.4.0.0/gatk ApplyBQSR \
                -I $inputfileDir/$sample.sorted.dup.rg.bam \
                -R ${workindir}/Aclarkii_genome.fasta \
                --bqsr-recal-file ${caldir}/$sample.bqsr.report \
                -O ${workindir}/09_calibrated_bam/$sample.calibrated.bam


