#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1:00:00
#SBATCH --mem=40G
#SBATCH -c 8
#SBATCH --job-name=sep.gene
#SBATCH --output=outscripts/sep.gene.%j.out
#SBATCH --error=outscripts/sep.gene.%j.err

ml samtools/1.9
bcftools/1.16-1
ml bedtools

# Required files
ref=Aclarkii_genome.mito.fasta
gff=Aclarkii_annotation.mito.gff3
bamdir=mito_bams
outdir=mito_results/new
mkdir -p "$outdir"

# Loop over each sample
while read sample; do
  echo "Processing $sample..."

  # Loop over each gene (from the BED file)
  while read chr start end gene; do
    outdir_gene="$outdir/$gene"
    mkdir -p "$outdir_gene"

    bedtools getfasta \
      -fi "$outdir/${sample}.consensus.fasta" \
      -bed <(echo -e "$chr\t$start\t$end\t$gene") \
      -name \
      -fo "$outdir_gene/${sample}.${gene}.fasta"

  done < "$outdir/mito_cds.bed"

done < new_fastq.txt

# finally I manually added the genes of the other species pairs at the end of these gene-wise fasta files. 
