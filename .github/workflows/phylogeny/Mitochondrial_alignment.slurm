#!/bin/bash
#SBATCH -p compute
#SBATCH -t 10:00:00
#SBATCH --mem=10G
#SBATCH -c 4
#SBATCH --job-name=bwa_mem
#SBATCH --output=outscripts/bwa.%j.out
#SBATCH --error=outscripts/bwa.%j.err
#SBATCH --array=1-45

ml bwa.icc/0.7.10
ml samtools
ml bedtools

# Set number of threads and mito reference
ref=Aclarkii_genome.mito.fasta # Tao et al., 2016
gff=Aclarkii_annotation.mito.gff3
SAMPLE_LIST=samples.fastq_new.txt #file with sample names and directory for each trimmed file

SampleList=Samples.txt   #list with sample names
mitoRef=Aclarkii_genome.mito.fasta

# Extract sample and directory for current task
sample=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line {print $1}' $SampleList)
dir=/bucket/LaudetU/Jann/clarkii_genomics/02_trimmed

# FASTQ file paths
R1=${dir}/${sample}_1_trimmed_paired.fastq.gz
R2=${dir}/${sample}_2_trimmed_paired.fastq.gz

# Output BAM files
paired_bam=${sample}.paired.bam

# Mapping paired-end reads
bwa mem -t $SLURM_CPUS_PER_TASK $mitoRef $R1 $R2 | \
samtools view -b -F 0x904 - | \
samtools sort -@ $SLURM_CPUS_PER_TASK -o Samples/$paired_bam -

