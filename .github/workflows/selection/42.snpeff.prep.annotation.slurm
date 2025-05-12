#!/bin/bash
#SBATCH -p compute
#SBATCH -t 02:00:00
#SBATCH --mem=10G
#SBATCH -c 10
#SBATCH --mail-user=jann.zwahlen@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --job-name=bcftools_annotate
#SBATCH --output=bcftools.annotate%j.out

ml bioinfo-ugrp-modules  DebianMed/12.0
ml bcftools/1.16-1
genomeDir=/flash/LaudetU/Jann/Salamin_sequences
inDir=/flash/LaudetU/Jann/Salamin_sequences/11_filtered.uncalibrated
bcftools annotate -c ID -a ${genomeDir}/Aclarkii_genome.fasta -c CHROM,FROM,TO ${inDir}/worldwide.uncalibrated_SNP.filtered.MD8.vcf.gz -o SNPS.bcftools.anno.vcf
