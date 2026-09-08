#!/bin/bash

#SBATCH --job-name=makebed
#SBATCH --partition=compute
#SBATCH -c 20
#SBATCH --mem=50G
#SBATCH --output=makebed.%j.out
#SBATCH --error=makebed.%j.err
#SBATCH --time=04:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Jann.zwahlen@oist.jp

plink --vcf /allchr.allsamples.filter.nochry.vcf.gz --double-id --allow-extra-chr --make-bed --out new_allsamples_nochry_filter

# perform linkage pruning - i.e. identify prune sites
VCF=/flash/LaudetU/Jann/clarkii_genomics/allchr.allsamples.filter.nochry.vcf.gz
/apps/unit/LaudetU/plink --vcf $VCF --double-id --allow-extra-chr \
--set-missing-var-ids @:# --extract  newallchr24.allsamples.filter.nochry.strict.prune.in --make-bed \
--indep-pairwise 50 5 0.2 --out allchr24.allsamples.filter.nochry.strict

/apps/unit/LaudetU/plink --bfile allchr24.allsamples.filter.nochry.strict --double-id --allow-extra-chr --set-missing-var-ids @:# \
--pca --out allchr24.allsamples.filter.nochry.strict

