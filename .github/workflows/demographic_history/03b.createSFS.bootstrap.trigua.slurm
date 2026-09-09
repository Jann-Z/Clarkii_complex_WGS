#!/bin/bash
#SBATCH --job-name=bootstrap
#SBATCH --output=bootstrap_%j.out
#SBATCH --error=bootstrap_%j.err
#SBATCH -c 10
#SBATCH --mem=50G
#SBATCH --time=8:00:00
#SBATCH --partition=compute

# change .par file with the best likelihood estimates according to FSC manual
/apps/fastsimcoal28/fsc28 -i TriAnc_02.par -n100 -j -m -s0 -x –I -q
