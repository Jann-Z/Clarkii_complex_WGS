#!/bin/bash

ml vcflib
ml bcftools
ml tabix
ml python/3.7.3

#### Nuclear tree whole genome ####
## prepare files
# create pruned VCF
/apps/plink --bfile allchr.allsamples.filter.strict --recode vcf-iid --out allchr.allsamples.filter.strict
# subsample SNPs (5%)
bcftools view allchr.allsamples.filter.strict.vcf | vcfrandomsample -r 0.05 > allsamples_pruned_subset.vcf


# create phylip / fasta files
python vcf2phylip.py -i allsamples_pruned_subset.vcf --output-folder vcf2phylip -m 40 -f

# run first IQtree to create varsites.phy file 
iqtree2 -nt AUTO -s ./vcf2phylip/allsamples_pruned_subset.min40.fasta -st DNA -m GTR+ASC --prefix subset_allchr.allsamples_pruned
# run modelfinder 
iqtree2 -nt AUTO -s subset_allchr.allsamples_pruned.varsites.phy -st DNA -m MFP+ASC --prefix subset_MFperp_allchr.allsamples_pruned 
# run the best model -alrt and bootstrap (modelfinder did not allow -alrt)
iqtree2 -nt AUTO -s subset_allchr.allsamples_pruned.varsites.phy -st DNA -m TVM+F+ASC+R5 -alrt 1000 -B 1000 --prefix subset_best_allchr.allsamples_pruned

#use .treefile to create the tree in figtree

#### Nuclear tree per chromosome ####
# ANGSD previously produced .bcf files, convert them to .vcf, using array
#SBATCH --array=1-24
bcftools view chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf.bcf -Oz -o chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf.vcf.gz

# vcf2phylip
python vcf2phylip.py -i chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf.vcf.gz --output-folder vcf2phylip -m 40 -f
# run iqtree to get varsites.phy
iqtree2 -nt AUTO -s ./vcf2phylip/chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf.min40.fasta -st DNA -m GTR+ASC --prefix chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf
# run iqtree again
iqtree-2.1.3-Linux/bin/iqtree2 -nt AUTO -s chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf.varsites.phy -st DNA -m GTR+ASC -B 1000 --prefix chr${SLURM_ARRAY_TASK_ID}.allsamples.nomaf
