#!/bin/bash
#SBATCH --job-name=CenOgaMel_GF
#SBATCH --output=outscripts/fastsimcoal2_%A_%a.out
#SBATCH --error=outscripts/fastsimcoal2_%A_%a.err
#SBATCH -c 1
#SBATCH --mem=10G
#SBATCH --time=48:00:00
#SBATCH --partition=compute
#SBATCH --array=1-100  # Start at run 21 and run up to 100, with 20 parallel jobs

PREFIX=CenOgaMel_GF
FSC28=/apps/fastsimcoal28/fsc28

# Set the directory and run number based on the SLURM array task ID
run_num=$SLURM_ARRAY_TASK_ID
run_dir="run${run_num}"

# Create directory for this run and copy necessary files
mkdir "$run_dir"
cp ${PREFIX}.tpl ${PREFIX}.est ${PREFIX}_jointMAF*.obs "$run_dir/"

# Change to the run directory
cd "$run_dir"

# Run fastsimcoal2
${FSC28} -t "${PREFIX}.tpl" -e "${PREFIX}.est" -m -C 5 -n 200000 -L 50 -s 0 -M -0

# The script automatically ends after each array job completes
