# Load required libraries
install.packages("R.utils")
library(rehh)
library(tidyverse)

# Define chromosomes to process
chromosomes <- 1

# Read GFF file and prepare it
gff <- read.table("./A.clarkii_Final_Annotation.gff3", header = FALSE, sep = "\t")
colnames(gff) <- c("chr", "source", "feature", "start", "end", "score",
                   "strand", "frame", "attribute")
gff <- gff %>%
  filter(feature == "gene") %>%
  arrange(start, end) %>%
  mutate(mid = start + (end - start) / 2)

# Iterate over chromosomes
for (chr in chromosomes) {
  cat("Processing chromosome", chr, "...\n")
  
  # Define file paths
  chr_label <- paste0("chr", chr)
  ogasawara_file <- paste0("./ogasawara_", chr_label, ".vcf.gz")
  japan_file <- paste0("./japan_", chr_label, ".vcf.gz")
  
  # Read in data for each population
  ogasawara_hh <- data2haplohh(hap_file = ogasawara_file, polarize_vcf = FALSE)
  japan_hh <- data2haplohh(hap_file = japan_file, polarize_vcf = FALSE)
  
  # Filter on MAF
  ogasawara_hh_f <- subset(ogasawara_hh, min_maf = 0.05)
  japan_hh_f <- subset(japan_hh, min_maf = 0.05)
  
  # Perform scans
  ogasawara_scan <- scan_hh(ogasawara_hh_f, polarized = FALSE)
  japan_scan <- scan_hh(japan_hh_f, polarized = FALSE)
  
  # Perform iHS
  ogasawara_ihs <- ihh2ihs(ogasawara_scan, freqbin = 1)
  japan_ihs <- ihh2ihs(japan_scan, freqbin = 1)
  
  # Save iHS plots
  plot_ogasawara_ihs <- ggplot(ogasawara_ihs$ihs, aes(POSITION, IHS)) + geom_point() + ggtitle(paste("ogasawara IHS", chr_label))
  ggsave(plot = plot_ogasawara_ihs, filename = paste0("ogasawara_IHS_", chr_label, ".pdf"))
  
  plot_ogasawara_logpval <- ggplot(ogasawara_ihs$ihs, aes(POSITION, LOGPVALUE)) + geom_point() + ggtitle(paste("ogasawara IHS LOGPVALUE", chr_label))
  ggsave(plot = plot_ogasawara_logpval, filename = paste0("ogasawara_IHS_logpval_", chr_label, ".pdf"))
  
  plot_japan_ihs <- ggplot(japan_ihs$ihs, aes(POSITION, IHS)) + geom_point() +ggtitle(paste("japan IHS", chr_label))
  ggsave(plot = plot_japan_ihs, filename = paste0("japan_IHS_", chr_label, ".pdf"))
  
  plot_japan_logpval <- ggplot(japan_ihs$ihs, aes(POSITION, LOGPVALUE)) + geom_point() + ggtitle(paste("japan IHS LOGPVALUE", chr_label))
  ggsave(plot = plot_japan_logpval, filename = paste0("japan_IHS_logpval_", chr_label, ".pdf"))
 
  # Perform xpEHH
  ogasawara_japan <- ies2xpehh(japan_scan, ogasawara_scan,
                               popname1 = "japan", popname2 = "ogasawara",
                               include_freq = TRUE)
  
  # Save xpEHH plots
  plot_xpehh <- ggplot(ogasawara_japan, aes(POSITION, XPEHH_japan_ogasawara)) +
    geom_point() +
    ggtitle(paste("ogasawara-japan XPEHH", chr_label))
  ggsave(plot = plot_xpehh, filename = paste0("ogasawara_japan_XPEHH_", chr_label, ".pdf"))
  
  plot_xpehh_logpval <- ggplot(ogasawara_japan, aes(POSITION, LOGPVALUE)) +
    geom_point() +
    ggtitle(paste("ogasawara-japan XPEHH LOGPVALUE", chr_label))
  ggsave(plot = plot_xpehh_logpval, filename = paste0("ogasawara_japan_XPEHH_logpval_", chr_label, ".pdf"))
  
  # Find top hit and calculate haplotype structure
  top_hit <- ogasawara_japan %>% arrange(desc(LOGPVALUE)) %>% slice(1)
  x <- top_hit$POSITION
  
  marker_id_o <- which(ogasawara_hh_f@positions == x)
  marker_id_m <- which(japan_hh_f@positions == x)
  
  ogasawara_furcation <- calc_furcation(ogasawara_hh_f, mrk = marker_id_o)
  japan_furcation <- calc_furcation(japan_hh_f, mrk = marker_id_m)
  
  ogasawara_haplen <- calc_haplen(ogasawara_furcation)
  japan_haplen <- calc_haplen(japan_furcation)
  
  # Save haplotype structure plots
  pdf(paste0("ogasawara_haplen_top1_", chr_label, ".pdf"))
  plot(ogasawara_haplen)
  dev.off()
  
  pdf(paste0("japan_haplen_top1_", chr_label, ".pdf"))
  plot(japan_haplen)
  dev.off()
  
  # Save xpEHH results
  ogasawara_japan <- tibble::as_tibble(ogasawara_japan)
  colnames(ogasawara_japan) <- tolower(colnames(ogasawara_japan))
  write_tsv(ogasawara_japan, paste0("ogasawara_japan_xpEHH_", chr_label, ".tsv"))
  
  # Identify candidate genes near top hit
  gene_hits <- gff %>%
    filter(chr == chr_label) %>%
    mutate(hit_dist = abs(mid - x)) %>%
    arrange(hit_dist) %>%
    filter(hit_dist < 250000) %>%
    select(chr, start, end, attribute, hit_dist)
  
  write.csv(gene_hits, paste0("ogasawara_japan_gene_hits_", chr_label, ".csv"))
}

cat("All chromosomes processed.\n")
