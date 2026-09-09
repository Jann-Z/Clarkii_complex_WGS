#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 12:00:00
#SBATCH --mem=500G
#SBATCH -c 20  #run time not reduced with more than 2cpus
#SBATCH --job-name=easySFS.proj
#SBATCH --output=easySFS.proj_%j.out


VCF=CenTriGuaMel_allchr_filter_pruned_SFS.vcf.gz
easySFS=easySFS/easySFS.py
#conda activate easySFS
ml python/3

#estimates from the preview:
$easySFS -i $VCF -p samples.TRIGUA -f -v --preview
$easySFS -i $VCF -p samples.OGA -f -v --preview

# for tricinctus and guam (order: MEL,CEN,GUA,TRI)
$easySFS -i $VCF -p samples.TRIGUA -f -a -v --proj 28,92,6,6

# for ogasawara (order: OGA,MEL,CEN)
$easySFS -i $VCF -p samples.OGA -f -a -v --proj 20,22,108
