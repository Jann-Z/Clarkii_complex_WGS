# A. Marcionetti, Oct 2024

import sys

def get_region_of_interest(input_file_name):
        # The file should be in the format of Chrom\tstart\tend
        Regions_of_interest = {}
        first_line = True
        input_file = open(input_file_name, "r")
        for line in input_file:
                line = line.rstrip()
                if first_line:
                        #check delimiter
                        if "\t" in line:
                                delimit = "\t"
                        elif "," in line:
                                delimit = ","
                        else:
                                print("Delimited of columns is not clear. Please use tab or comma separated values.")
                                break

                        first_line = False
                        continue
                line_list = line.split(delimit)
                # Check if "chr"is in the chromosome name. If not, add it to be able to compare with the annotation file
                if "chr" in line_list[0]:
                        chrom= line_list[0]
                else:
                        chrom = "chr"+line_list[0]
                start =  int(line_list[1])
                end =  int(line_list[2])

                if chrom not in Regions_of_interest.keys():
                        Regions_of_interest[chrom] = [(start, end)]
                else:
                        Regions_of_interest[chrom].append((start, end))

        input_file.close()

        return(Regions_of_interest)


def check_if_overalpping(gstart, gstop, cand_start, cand_stop):

        # Overlap if the beginning of the gene or the end of the gene are in the candidate location
        if gstart > cand_start and gstart < cand_stop:
                return True
        elif gstop > cand_start and gstop < cand_stop:
                return True
        else:
                return False
def get_gene_info_from_gff3(line_of_gff3):
        line_of_gff3 = line_of_gff3.split("\t")
        chrom = line_of_gff3[0]
        start = int(line_of_gff3[3])
        stop = int(line_of_gff3[4])
        index = line_of_gff3[-1].find("=")
        gene_name = line_of_gff3[-1][index+1:]
        return chrom, start, stop, gene_name


def print_gene_to_files(Overlapping_genes_dictionary, output_file_prefix):

        out_file_list = open(output_file_prefix+".geneList", "w")
        out_file_fullInfo = open(output_file_prefix+".genePositions", "w")
        print("Gene\tchrom\tGene_start\tGene_stop\tWindow_start\tWindow_stop", file=out_file_fullInfo)


        for gene in Overlapping_genes_dictionary.keys():

                # print the gene name in the file .genelist
                print(gene, file=out_file_list)

                # print the full info in the file .genePositions
                print(gene + "\t"+"\t".join(Overlapping_genes_dictionary[gene]), file=out_file_fullInfo)

        out_file_list.close()
        out_file_fullInfo.close()


#####
#       USAGE
#
#       python Extract_Genes_CandidateRegions.py File_name_with_regions gff3_annotation out_prefix
#
# where:
#       File_name_with_regions: name of the file where the regions of interest are found. Format: chrom,start,stop or chrom\tstart\tstop
#       gff3_annotation:                name of the genome annotation file in gff3 format
#       out_prefix:                     prefix for the output files. The script will create prefix.geneList and prefix.genePositions with the info
#                                                       on the genes overlapping the regions of interest.
#
#
####

input_regions = sys.argv[1]                     # name of the file where the regions of interest are found. Format: chrom,start,stop or chrom\tstart\tstop
input_gff3 = sys.argv[2]                        # name of the annotation file in gff3 format
output_file_prefix = sys.argv[3]        # prefix for output file. The script will create prefix.geneList and prefix.genePositions with the info \
                                                                        # on the genes overlapping the regions of interest.

# Get region of interest
regions = get_region_of_interest(input_regions)

# parse the gff and see if genes overlapp the windows
input_file = open(input_gff3)

Genes_Overlapping = {}

for line in input_file:
        line = line.rstrip()

        if not ( len(line.split("\t")) > 1 and line.split("\t")[2] == "gene" ): #We do not consider the first line and lines not describing genes
                continue

        # Get info on the gene
        g_chrom, g_start, g_stop, g_name = get_gene_info_from_gff3(line)

        # See if the gene overlap one of the regions of interest
        if g_chrom not in regions.keys():
                #print("No region of interest in chromosome "+g_chrom)
                continue

        for reg in regions[g_chrom]:
                overlap = check_if_overalpping(g_start, g_stop, reg[0], reg[1])
                if overlap:

                        Genes_Overlapping[g_name] = [g_chrom, str(g_start),str(g_stop), str(reg[0]), str(reg[1])]

input_file.close()

# print genes
print_gene_to_files(Genes_Overlapping, output_file_prefix)





