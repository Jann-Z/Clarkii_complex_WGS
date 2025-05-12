##copy relevant files (With Ogasawara) to ./ogasawara
# Load required library
library(dplyr)

# Set the directory containing your *.weir.fst files
input_dir <- "ogasawara"
output_file <- "common.fst1.txt"

# Get the list of all *.weir.fst files
fst_files <- list.files(input_dir, pattern = "*.weir.fst", full.names = TRUE)

# Initialize a list to store filtered data
filtered_snps <- list()

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
}

# Find common SNPs across all comparisons
common_snps <- Reduce(function(x, y) inner_join(x, y, by = c("CHROM", "POS")), filtered_snps)

# Write the result to the output file
write.table(common_snps, file = output_file, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Print completion message
cat("Common SNPs with Fst = 1 written to", output_file, "\n")
