#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 128:00:00
#SBATCH --mem=20G
#SBATCH -c 2  #run time not reduced with more than 2cpus
#SBATCH --job-name=BaseRecalibration2nd
#SBATCH --output=base.recalibration2nd_%a.out
#SBATCH --error=base.recalibration2nd_%a.err
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=Jann.zwahlen@oist.jp


##############################
# Argument to pass:
SampleList=${1-AllSamplesWorldwide.txt}                  # Name of the file with sample names. Default: AllSamples.txt
workindir=${2-.}                                        # Working directory. Default: Current Directory
inputfileDir=${3-/bucket/LaudetU/Jann/Salamin_sequences/07_sort.dup.rg}                       # Name of the directory with the input mapping files (should be in workindir). Default: $
variantdir=${4-/flash/LaudetU/Jann/WGS/14_called.variants.second.combined}
outdir=${5-12_calibrated.variants}
##############################


############################################################
## Relaunch the script as array with the number of jobs corresponding to the number of files
nline=$(wc -l $SampleList | awk '{print $1}')


if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
     # Relaunch this script as an array
     exec sbatch --array=1-$nline $0 $SampleList $workindir $inputfileDir $variantdir $outdir
fi

############################################################
# Check settings
echo "Using following arguments:

List of Samples:        "$SampleList"
Working directory:      "$workindir"
Mapping Files directory (if relative path, from "$workindir") : "$inputfileDir"
Variant directory:      "$variantdir"
Outfile directory:      "$outdir"

If settings are wrong, please look at instructions and arguments to pass

"
####################
# LOAD MODULES
####################

ml load java-jdk/17

####################
# BEGINNNING OF SCRIPT
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

/apps/unit/LaudetU/Emma/gatk-4.4.0.0/gatk BaseRecalibrator \
                -I $inputfileDir/$sample.sorted.dup.rg.bam \
                -R ${workindir}/Aclarkii_genome.fasta \
                --known-sites ${variantdir}/all.snps.filtered.2nd.vcf.gz \
                -O ${outdir}/$sample.bqsr.report


####################
# END
####################

echo "The script for sample "$sample" has finished"
