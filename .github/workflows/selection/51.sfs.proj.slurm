#!/bin/bash
#SBATCH --partition=compute
#SBATCH -t 1:00:00
#SBATCH --mem=500G
#SBATCH -c 20  #run time not reduced with more than 2cpus
#SBATCH --job-name=easySFS.proj
#SBATCH --output=easySFS.proj_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jann.zwahlen@oist.jp

VCF=/flash/LaudetU/Jann/Salamin_sequences/11_filtered.uncalibrated/for.sfs.uncalibrated2-S67.vcf.gz
easySFS=/apps/unit/LaudetU/easySFS/easySFS.py

$easySFS -i $VCF -p pop_file3 -f -a -v --proj 52,14,6,20
