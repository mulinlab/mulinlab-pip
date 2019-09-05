#!/bin/Rscript

library(tidyverse)
library(pheatmap)

args <- commandArgs(trailingOnly=TRUE)

did <- file.path(args[1], "deg")
dis <- list.files(did)

dop <- file.path(args[1], "plot_deg")
dopp <- file.path(dop, "heatmap")
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
    df <- read_tsv(fi) %>% filter(padj<=0.05 & abs(log2FC)>=1)
    df <- df %>% group_by(symbol) %>% top_n(-1, padj) %>% top_n(1, abs(log2FC)) %>% ungroup()
    df <- df %>% top_n(-100, padj) %>% top_n(100, abs(log2FC)) %>% select(-c(GeneID, log2FC, lfcSE, pvalue, padj)) %>% select(rev(order(colnames(.)))) %>% column_to_rownames(var="symbol")
    df[is.na(df)] <- mean(as.matrix(df), na.rm=TRUE)
    if(str_detect(db, "salmon") | str_detect(db, "stringtie")){
      df <- log10(df)
    }else{
      df <- log10(df)
    }
    df[is.infinite(as.matrix(df))] <- min(!is.infinite(as.matrix(df)))
    
    anno <- data.frame(id=colnames(df), id1=colnames(df)) %>% separate(id1, into=c("group", "GSE")) %>% select(-GSE)
    anno <- anno %>% arrange(desc(group)) %>% column_to_rownames(var="id")
    anno$group <- str_replace(anno$group, "_rep\\d+", "")
    
    fo <- file.path(do, paste0(sid, ".png"))
    png(filename=fo, height=4096, width=3072, res=200)
    pheatmap(df, cluster_cols=FALSE, annotation_col=anno)
    dev.off()
  }
}

