#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 24:00:00
#SBATCH --mem=80G
#SBATCH -c 10
#SBATCH --job-name=markdup.L
#SBATCH --output=markdup.L.%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jann.zwahlen@oist.jp

module load picard/2.7.0

inDir=/flash/LaudetU/Jann/Salamin_sequences/05_sort
outDir=/flash/LaudetU/Jann/Salamin_sequences/06_sort.dup

# Set the number of jobs you want to run in parallel (adjust as needed)
num_parallel=10

# Function to run markdup on a single sample
process_sample() {
    sample_id=$1
    java -jar /apps/free81/picard/2.7.0/bin/picard.jar MarkDuplicates \
            REMOVE_DUPLICATES=TRUE \
            I=${inDir}/${sample_id}.sorted.bam \
            O=${outDir}/${sample_id}.sorted.dup.bam \
            METRICS_FILE=${outDir}/${sample_id}.dup.metrics \
            CREATE_INDEX=true
}

# Loop through numbers 29150595 to 29150661
for i in {29150595..29150661}; do
    sample_id="SRR$i"

    # Run Mark duplicates
    process_sample $sample_id &

    # If the number of background jobs reaches the limit, wait for them to finish
    if [[ $(jobs -r -p | wc -l) -ge $num_parallel ]]; then
        wait -n  # Wait for any background job to finish before continuing
    fi
done

# Wait for all background jobs to finish
wait
