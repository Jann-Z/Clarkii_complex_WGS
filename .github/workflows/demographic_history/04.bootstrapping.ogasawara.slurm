#!/bin/bash
#SBATCH --job-name=bootstrap_new
#SBATCH --output=outscripts/bootstrap_%A_%a.out
#SBATCH --error=outscripts/bootstrap_%A_%a.err
#SBATCH -c 7
#SBATCH --mem=50G
#SBATCH --time=96:00:00
#SBATCH --partition=compute
#SBATCH --array=1-100

FSC28=/apps/fastsimcoal28/fsc28
PREFIX=CenOgaMel_GF
array_num=$SLURM_ARRAY_TASK_ID

export FSC28
export PREFIX


cd ${PREFIX}_${array_num}
seq 1 30 | xargs -P 7 -I {} bash -c '                 # to run 30 runs per SFS, 7 at a time
    mkdir -p run{}                                    # create run directories
    cd run{}                                          # go to run direcotries and copy files (next lines)
    cp ../${PREFIX}_*.obs ./
    cp ../../${PREFIX}.tpl ./
    cp ../../${PREFIX}.est ./
    ${FSC28} -t "${PREFIX}.tpl" -e "${PREFIX}.est" -m -C 5 -n 200000 -L 20 -s 0 -M -0 -q         # simulate data for bootstrapping
'
