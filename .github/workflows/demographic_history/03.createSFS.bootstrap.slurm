#!/bin/bash
#SBATCH --job-name=bootstrap
#SBATCH --output=bootstrap_%j.out
#SBATCH --error=bootstrap_%j.err
#SBATCH -c 10
#SBATCH --mem=50G
#SBATCH --time=48:00:00
#SBATCH --partition=compute

# create SFS files for bootstrap. change .par file accordingly, as per the FSC manual.
/apps/fastsimcoal28/fsc28 -i CenOgaMel_GF.par -n100 -j -m -s0 -x –I -q
