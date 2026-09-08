library(tidyr)
library(tidyverse)
#### PCA  ####
# Load files
pop <- read.table("AllSamples_col.txt", header = FALSE,comment.char = "") #each row with sample name, population, colour
colnames(pop) <- c("sample", "population", "colour")
pca <- read_table("allchr.allsamples.filter.nochry.strict.eigenvec", col_names = FALSE)
eigenval <- scan("allchr.allsamples.filter.nochry.strict.eigenval")
# remove nuisance column
pca <- pca[,-1]
# set names
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))
pve <- data.frame(PC = 1:20, pve = eigenval/sum(eigenval)*100)
a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") + theme_light()
axis_ratio <- pve$pve[2] / pve$pve[1]
b1 <- ggplot(pca, aes(PC1, PC2, color = pop$colour)) +
  geom_point(size = 5) +
  geom_vline(xintercept = 0, linetype = 2, linewidth = 0.5, color = "lightgrey") +
  geom_hline(yintercept = 0, linetype = 2, linewidth = 0.5, color = "lightgrey") +
  scale_color_identity() +
  xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)")) +
  theme_bw() +
  theme(axis.title = element_text(colour = "black", size = 13),
        axis.text = element_text(colour = "black", size = 12),
        axis.ticks = element_line(colour = "black", linewidth = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(color = guide_legend(title = "Condition"))
b2 <- ggplot(pca, aes(PC3, PC4, color = pop$colour)) +
  geom_point(size = 5) +
  geom_vline(xintercept = 0, linetype = 2, linewidth = 0.5, color = "lightgrey") +
  geom_hline(yintercept = 0, linetype = 2, linewidth = 0.5, color = "lightgrey") +
  scale_color_identity() +
  xlab(paste0("PC3 (", signif(pve$pve[3], 3), "%)")) +
  ylab(paste0("PC4 (", signif(pve$pve[4], 3), "%)")) +
  theme_bw() +
  theme(axis.title = element_text(colour = "black", size = 13),
        axis.text = element_text(colour = "black", size = 12),
        axis.ticks = element_line(colour = "black", linewidth = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(color = guide_legend(title = "Condition"))

ggsave("PCA_PC1_PC2.png", b1, width = 6, height = 5, units = "in", dpi = 600)
ggsave("PCA_PC3_PC4.png", b2, width = 6, height = 5, units = "in", dpi = 600)


#### ADMIXTURE ####
pop <- read.table("AllSamples_col.txt", header = FALSE) 
colnames(pop) <- c("sample","population") 
populations <- pop$population 
populations <- factor(populations, levels = c("NewCal","Solomon","PNG","Tricinctus","Guam","Ogasawara","Japan","Ryukyu","Taiwan","Philippines","Sulawesi","Bali","Thailand","Maldives")) 
#load q-file
admix <- read.table("allchr24.allsamples.filter.nochry.strict.5.Q", header = FALSE)
admix_t <- as.matrix(admix)   # rows = samples, cols = K clusters

#admix_t <- t(admix) # now it's 166 rows (samples) × 4 cols (clusters) 
ord <-order(populations) 
admix_ord <- admix_t[ord, ] 
pop_ord <- populations[ord]
my_colours <- c("#F1932D","#DC050C","#1965B0","#994F88","#F7F056")

# ---- Save as PNG ---- Barplot
png("admixture_K5_barplot.png", width = 3000, height = 1200, res = 300)
barplot(t(admix_ord), col = my_colours, space = 0, border = NA, ylab = "Admixture proportion")
# Population labels
text(x = tapply(1:length(pop_ord), pop_ord, mean), y = -0.05, labels = unique(pop_ord), xpd = TRUE)
# Lines between populations
abline(v = cumsum(table(pop_ord)), lty = 2, col = "white")
dev.off()

