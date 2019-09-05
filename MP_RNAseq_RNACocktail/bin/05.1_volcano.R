#!/bin/Rscript

library(tidyverse)
library(ggrepel)

args <- commandArgs(trailingOnly=TRUE)

did <- file.path(args[1], "deg")
dis <- list.files(did)

dop <- file.path(args[1], "plot_deg")
dopp <- file.path(dop, "valcano")
dir.create(dopp, showWarnings=FALSE, recursive=TRUE)


for (db in dis){
  di <- file.path(did, db)
  if(str_detect(db, "salmon") | str_detect(db, "stringtie")){
    fs <- list.files(di, pattern="*tpm.txt")
  }else{
    fs <- list.files(di, pattern="*count.txt")
  }
  do <- file.path(dopp, db)
  dir.create(do, showWarnings=FALSE)
  
  for (bn in fs){
    sid <- str_replace(bn, "deg_", "")
    sid <- str_replace(sid, "_count.txt", "")
    sid <- str_replace(sid, "_tpm.txt", "")
    
    fi <- file.path(di, bn)
    df <- read_tsv(fi) %>% select(gene=symbol, log2FC, pvalue, padj) %>% distinct() %>% drop_na()
    df$Significant <- as.factor(ifelse(df$padj<=0.05 & abs(df$log2FC)>=1, ifelse(df$log2FC>=1, "Expression Up", "Expression Down"), "Not Significant"))
    labs <- subset(df, padj<=0.05 & abs(df$log2FC)>=1)
    labs <- labs %>% top_n(-100, padj) %>% top_n(100, abs(log2FC))
    
    fo <- file.path(do, paste0(sid, ".png"))
    gv <- ggplot(df, aes(x=log2FC, y=-log10(padj))) +
      geom_point(aes(color=Significant)) +
      scale_color_manual(values=c("#5199CF", "#FF736B", "grey")) +
      theme_bw(base_size=12) + theme(legend.position="bottom") +
      xlab("log2(Fold Change)") + ylab("-log10(Adjust p-value)") + 
      geom_text_repel(
        data=labs,
        aes(label=gene),
        size=3,
        box.padding=unit(0.35, "lines"),
        point.padding=unit(0.3, "lines")
      )
    ggsave(fo, gv, width=12, height=15)
  }
}
