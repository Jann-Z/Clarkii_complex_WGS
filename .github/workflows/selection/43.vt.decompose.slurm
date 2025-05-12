#!/bin/bash
#SBATCH -p compute
#SBATCH -t 10:00:00
#SBATCH --mem=20G
#SBATCH -c 20
#SBATCH --mail-user=jann.zwahlen@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --job-name=vt_decompose
#SBATCH --output=vt.decompose%j.out

ml bioinfo-ugrp-modules  DebianMed/11.2
ml bioinfo-ugrp-modules  DebianMed/12.0
ml vt

vt decompose -s -o SNPS.bcftools.anno.deco.vcf SNPS.bcftools.anno.vcf
