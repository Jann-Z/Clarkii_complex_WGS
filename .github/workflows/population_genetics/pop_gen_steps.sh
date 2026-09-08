#!/bin/bash
# recommended to split it up into multiple steps. 

VCF=allchr.allsamples.filter.nochry.vcf.gz

### linkage pruning -identify prune sites
/apps/plink --vcf $VCF --double-id --chr-set 24 no-xy no-y no-mt --allow-extra-chr \
--set-missing-var-ids @:# --make-bed \
--indep-pairwise 50 5 0.2 --out allchr.allsamples.filter.nochry.strict

### linkage pruning - extract prune sites
/apps/plink --vcf $VCF --double-id --allow-extra-chr \
--set-missing-var-ids @:# --extract  newallchr24.allsamples.filter.nochry.strict.prune.in --make-bed \
--indep-pairwise 50 5 0.2 --out allchr.allsamples.filter.nochry.strict

### run PCA
/apps/plink --bfile allchr.allsamples.filter.nochry.strict --double-id --allow-extra-chr --set-missing-var-ids @:# \
--pca --out allchr.allsamples.filter.nochry.strict

### admixture
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 2 > pruned_allsamples_filter.log2.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 3 > pruned_allsamples_filter.log3.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 4 > pruned_allsamples_filter.log4.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 5 > pruned_allsamples_filter.log5.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 6 > pruned_allsamples_filter.log6.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 7 > pruned_allsamples_filter.log7.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 8 > pruned_allsamples_filter.log8.out
/apps/admixture/1.3.0/admixture --cv allchr.allsamples.filter.nochry.strict.bed 9 > pruned_allsamples_filter.log9.out

### population genomics : 
# Scripts from Simon Martin genomics_general: https://github.com/simonhmartin/genomics_general
# First, create a .geno file:
python ./python/genomics_general/VCF_processing/parseVCF.py -i $VCF --ploidyMismatchToMissing \
--skipIndels --minQual 30 --gtf flag=DP min=5 max=50 -o allchr.allsamples.geno.gz
# Next, calculate population genetic indices using 5000 SNPs sliding windows. 
python ./python/genomics_general/popgenWindows.py -f phased --windType sites \
                -w 5000 -T 2 \
                -g allchr.allsamples.geno.gz \
                -o allchr.allsamples.5000snps.csv.gz \
                -p Ogasawara -p Guam -p Tricinctus -p Japan -p Ryukyus -p Taiwan -p Philippines -p Sulawesi -p Bali \
                -p Maldives -p Thailand -p PNG -p Solomon -p NewCal \
                --popsFile $poplabel #this file contains each sample + corresponding population per line

### Kinship analysis
# create un-pruned bed for kinship analysis
/apps/plink --vcf $VCF --double-id --allow-extra-chr --make-bed --out unpruned_allsamples_nochry_filter
# kinship (use --sexchr 25 to avoid getting chr24 dropped)
/apps/king -b unpruned_allsamples_nochry_filter.bed --kinship --sexchr 25 --prefix kinship_allsamples 

###RoH : parameters according to Foote et al. (2021)
/apps/plink --bfile allchr.allsamples.filter.nochry.strict --homozyg-snp 50 --homozyg-kb 300 --homozyg-density 50 \
--homozyg-gap 1000 --homozyg-window-snp 50 --homozyg-window-het 3 --homozyg-window-missing 10 --homozyg-window-threshold 0.05 --out ROH_allsamples_allchr
