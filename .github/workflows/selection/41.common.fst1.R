##copy relevant files (With Ogasawara) to ./ogasawara
# Load required library
library(dplyr)

# Set the directory containing your *.weir.fst files
input_dir <- "ogasawara"
output_common_file <- "G.common.fst1.txt"
output_summary_file <- "G.summary.fst1.txt"

# Get the list of all *.weir.fst files
fst_files <- list.files(input_dir, pattern = "*.weir.fst", full.names = TRUE)

# Initialize a list to store filtered data and a data frame for the summary
filtered_snps <- list()
summary_data <- data.frame(Comparison = character(), Fst1_Count = integer(), stringsAsFactors = FALSE)

# Loop through each file and filter SNPs with Fst = 1
for (file in fst_files) {
  # Read the file
  data <- read.table(file, header = TRUE, stringsAsFactors = FALSE)

  # Filter rows where Fst = 1
  fst1_snps <- data %>%
    filter(WEIR_AND_COCKERHAM_FST == 1) %>%
    select(CHROM, POS)

  # Store the filtered SNPs
  filtered_snps[[file]] <- fst1_snps

  # Extract the comparison name from the filename
  comparison_name <- gsub(".weir.fst", "", basename(file))

  # Add the number of Fst = 1 SNPs to the summary
  summary_data <- summary_data %>%
    add_row(Comparison = comparison_name, Fst1_Count = nrow(fst1_snps))
}

# Find common SNPs across all comparisons
common_snps <- Reduce(function(x, y) inner_join(x, y, by = c("CHROM", "POS")), filtered_snps)

# Write the common SNPs to the output file
write.table(common_snps, file = output_common_file, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Write the summary data to the summary file
write.table(summary_data, file = output_summary_file, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Print completion message
cat("Common SNPs written to", output_common_file, "\n")
cat("Summary of Fst = 1 counts written to", output_summary_file, "\n")
