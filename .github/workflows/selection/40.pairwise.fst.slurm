#!/bin/bash
#SBATCH -p compute
#SBATCH -t 12:00:00
#SBATCH --mem=50G
#SBATCH -c 10
#SBATCH --mail-user=jann.zwahlen@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --job-name=pairwise-fst
#SBATCH --output=pairwise.fst.%j.out

ml vcftools
VCF=/flash/LaudetU/Jann/Salamin_sequences/11_filtered.uncalibrated/worldwide.uncalibrated_SNP.filtered.MD8.vcf.gz
populations=("Ogasawara" "Mainland" "Ryukyu" "Guam" "Indonesia" "Taiwan" "Solomon" "Philippines" "PNG" "NewCal" "Maldives")

# Loop through all pairwise combinations of populations
for ((i = 0; i < ${#populations[@]}; i++)); do
  for ((j = i + 1; j < ${#populations[@]}; j++)); do
    pop1=${populations[i]}
    pop2=${populations[j]}

    # Run vcftools for the current pair of populations
    vcftools --gzvcf $VCF \
             --weir-fst-pop ${pop1}.txt \
             --weir-fst-pop ${pop2}.txt \
             --out ${pop1}_${pop2}
  done
done
