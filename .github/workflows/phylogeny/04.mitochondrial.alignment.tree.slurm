#!/bin/bash
#SBATCH -p compute
#SBATCH -t 5:00:00
#SBATCH --mem=40G
#SBATCH -c 8
#SBATCH --job-name=mafft
#SBATCH --output=outscripts/mafft.%j.out
#SBATCH --error=outscripts/mafft.%j.err

ml mafft
ml iqtree/2.2.2.5

fastaDir=Samples/fasta_final/clarkii
haploDir=haplotype_network
treeDir=trees/

### align the fasta with mafft

for file in $fastaDir/*_selection_renamed.fasta; do
    gene=$(basename "$file" .fasta)
    mafft --globalpair --maxiterate 1000 "$file" > "$treeDir/${gene}_aligned_out.fasta"
done

### create tree from the aligned fasta in the $treeDir

iqtree2 -p trees/ -B 1000 -T AUTO --prefix mitochondrial_clarkii
