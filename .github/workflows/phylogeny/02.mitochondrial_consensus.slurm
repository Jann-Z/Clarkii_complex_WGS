#!/bin/bash
#SBATCH -p compute
#SBATCH -t 30:00:00
#SBATCH --mem=40G
#SBATCH -c 8
#SBATCH --job-name=consensus
#SBATCH --output=outscripts/consensus.%j.out
#SBATCH --error=outscripts/consensus.%j.err

ml samtools/1.9
ml bedtools

# Required files
ref=Aclarkii_genome.mito.fasta
gff=Aclarkii_annotation.mito.gff3
bamdir=Samples
outdir=Samples/fasta
mkdir -p $outdir

# Convert GFF3 CDS to BED for bedtools
grep -i -w "CDS" $gff | awk -v OFS="\t" '{print $1, $4-1, $5}' > $outdir/mito_cds.bed

# Loop through samples
while read sample; do
  echo "Processing $sample..."
  samtools index $bamdir/${sample}.paired.bam

  # Variant calling
  bcftools mpileup -Ou -f $ref $bamdir/${sample}.paired.bam \
  | bcftools call -mv -Oz -o $outdir/${sample}.vcf.gz

  bcftools index $outdir/${sample}.vcf.gz

  # Consensus FASTA
  bcftools consensus -f $ref $outdir/${sample}.vcf.gz > $outdir/${sample}.consensus.fasta
done < AllSamples.txt
