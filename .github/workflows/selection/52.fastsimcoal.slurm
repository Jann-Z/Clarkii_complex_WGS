#!/bin/bash
#SBATCH --job-name=fastsimcoal2_OgaGuam
#SBATCH --output=outscripts/fastsimcoal2_%A_%a.out
#SBATCH --error=outscripts/fastsimcoal2_%A_%a.err
#SBATCH -c 10
#SBATCH --mem=10G
#SBATCH --time=96:00:00
#SBATCH --partition=compute
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jann.zwahlen@oist.jp
#SBATCH --array=1-100%20  # Start at run 21 and run up to 100, with 20 parallel jobs

PREFIX=Oga_Guam_Mig
FSC28=/apps/unit/LaudetU/fastsimcoal28/fsc28

# Set the directory and run number based on the SLURM array task ID
run_num=$SLURM_ARRAY_TASK_ID
run_dir="run${run_num}"

# Create directory for this run and copy necessary files
mkdir "$run_dir"
cp ${PREFIX}.tpl ${PREFIX}.est ${PREFIX}_jointMAFpop*.obs "$run_dir/"

# Change to the run directory
cd "$run_dir"

# Run fastsimcoal2
${FSC28} -t "${PREFIX}.tpl" -e "${PREFIX}.est" -m -C 10 -n 200000 -L 50 -s 0 -M

# The script automatically ends after each array job completes
