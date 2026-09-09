library(ape)
tree <- read.tree("subset_allchr.allsamples_pruned_clean.treefile")  #tree file of whole genome tree

# named vector: sample -> population, from your SETS.txt
sets <- read.table("AllSamplesPop.txt", sep = "\t", col.names = c("sample", "population"))

# pick one representative sample per population (first one encountered)
reps <- sets[!duplicated(sets$population), ]
# drop all tips except the chosen representatives
tree_pruned <- keep.tip(tree, reps$sample)

# relabel tips from sample name -> population name
tree_pruned$tip.label <- reps$population[match(tree_pruned$tip.label, reps$sample)]
is.binary(tree_pruned)
tree_pruned <- multi2di(tree_pruned)
tree_pruned <- root(tree_pruned, outgroup = "Outgroup", resolve.root = TRUE)

write.tree(tree_pruned, "population_tree_for_dsuite.out.nwk")
