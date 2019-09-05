#!/usr/bin/Rscript

library(tidyverse)
library(pheatmap)
library(RColorBrewer)
library(ggfortify)

args <- commandArgs(trailingOnly=TRUE)

tids <- c("stringtie", "salmon")

di <- file.path(args[1], "expression")
do <- file.path(args[1], "plot_expression")
dir.create(do, showWarnings=FALSE, recursive=TRUE)

for (tid in tids){
  fi <- file.path(di, tid, paste0(tid, "_tpm_gene.txt"))
  df <- read_tsv(fi)
  mat <- df %>% select(-c(geneID, symbol)) %>% t()
  
  # plot dist heatmap and clustering
  d <- dist(mat, method="manhattan")
  dm <- as.matrix(d)
  colnames(dm) <- NULL
  colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
  foc <- file.path(do, paste0(tid, "_clustering.png"))
  png(foc, width=2560, height=2048, res=300)
  pheatmap(dm,
           clustering_distance_rows=d,
           clustering_distance_cols=d,
           col=colors)
  dev.off()
  
  # plot PCA
  id <- rownames(mat)
  group <- str_replace(id, "_rep\\d+", "")
  dff <- cbind(id, group)
  fop <- file.path(do, paste0(tid, "_pca.png"))
  ga <- autoplot(prcomp(mat), data=dff, colour="group", label=TRUE, label.size=3)
  ggsave(fop, ga)
}
