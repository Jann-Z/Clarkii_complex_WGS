#!/bin/bash

#SBATCH --job-name=PopGenStats
#SBATCH --partition=compute
#SBATCH -c 20
#SBATCH --mem=50G
#SBATCH --output=outscripts/PopGenStats_uncalibrated.%j.out
#SBATCH --error=outscripts/PopGenStats_uncalibrated.%j.err
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Jann.zwahlen@oist.jp


#### The script is used to run the scripts of Simon Martin (https://github.com/simonhmartin/genomics_general) ####

##############################
# Argument to pass:
workdir=.
pyconvertvcf=python/genomics_general/VCF_processing/parseVCF.py
pywindow=python/genomics_general/popgenWindows.py
pyabba=python/genomics_general/ABBABABAwindows.py
inputfileDir=21_popgen
inputfile=new.snps.worldwide.calibrated.geno.gz
outputfileDir=21_popgen
poplabel=21_popgen/PopLabel.new.txt
minSNPs=100
windowsize=50000

#######################################
# Check the settings

echo "Using following setteings:

Input file:             "$inputfile"

Window type:    Coordinate
Examined window size:           "$windowsize" bp
Windows contain a minimum of "$minSNPs" SNPs

Please check the settings carefully!

-------------------------------------"



####################
# BEGINNING OF SCRIPT
####################
cd $workdir
# Compute standard population genomic statistics: pi, Fst, and dxy, for each pair of species
# Each population is listed using -p option
echo "Computing pi, Fst and dxy..."

python $pywindow -f phased --windType coordinate \
                -w $windowsize -m $minSNPs -T 2 \
                -g $inputfileDir"/"$inputfile \
                -o $outputfileDir"/4ind_popgenWindows.w50m100.csv.gz" \
                -p Ogasawara -p Guam -p Mainland -p Ryukyu \
                -p Taiwan -p Philippines -p Manado -p Tulamben -p Maldives \
                -p PNG -p Solomon_islands -p New_caledonia \
                --popsFile $poplabel

echo "Output file:      "$outputfileDir"/new.snps_popgenWindows.w50m50.csv.gz
echo "Script has finished!"

