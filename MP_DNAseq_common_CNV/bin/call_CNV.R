### loading packages
library(ExomeDepth)
library(GenomicRanges)
data(exons.hg19)
task_na='test'
bam_path <- '../input/'
out_path <- '../output/'
fasta <- '../ref/human_g1k_v37.fasta'
### loading bam files
bam_fn <- list.files(path = bam_path,pattern = '.bam$')
my.bam <- paste(bam_path,bam_fn,seq = "")
my.bam <- gsub(" ","",my.bam)
#### get the annotation datasets to be used later
data(Conrad.hg19)
exons.hg19.GRanges <- GRanges(seqnames = exons.hg19$chromosome,
                              IRanges(start=exons.hg19$start,end=exons.hg19$end),
                              names = exons.hg19$name)
                              
## call CNVs

### Create count data from BAM files

ExomeCount <- getBamCounts(bed.frame = exons.hg19,
                              bam.files = my.bam,
                              include.chr = FALSE,
                              referenceFasta = fasta)
ExomeCount.dafr <- as(ExomeCount[, colnames(ExomeCount)],'data.frame')
write.csv(ExomeCount.dafr,paste(out_path,"ExomeCount_",task_na,".csv",sep=""),quote = F)

### prepare the main matrix of read count data

ExomeCount.mat <- as.matrix(ExomeCount.dafr[, grep(names(ExomeCount.dafr), pattern = '*.bam')])
nsamples <- ncol(ExomeCount.mat)

### start looping over each sample

j = 0
for( j in 1:nsamples ){
  
  ### Build the most appropriate reference set
 
  my.choice <- select.reference.set (test.counts = ExomeCount.mat[,j],
                                     reference.counts = ExomeCount.mat[,-j],
                                     bin.length = (ExomeCount.dafr$end - ExomeCount.dafr$start)/1000,
                                     n.bins.reduced = 10000)
  print(my.choice[[1]])
  my.reference.selected <- apply(X = ExomeCount.mat[, my.choice$reference.choice, drop = FALSE],
                                 MAR = 1,
                                 FUN = sum)
  message('Now creating the ExomeDepth object')
  
  ### CNV calling
  
  all.exons <- new('ExomeDepth',
                   test = ExomeCount.mat[,j],
                   reference = my.reference.selected,
                   formula = 'cbind(test, reference) ~ 1')
  all.exons <- CallCNVs(x = all.exons,
                        transition.probability = 10^-4,
                        chromosome = ExomeCount.dafr$space,
                        start = ExomeCount.dafr$start,
                        end = ExomeCount.dafr$end,
                        name = ExomeCount.dafr$names)
  
  ### Better annotation of CNV calls
  
  all.exons <- AnnotateExtra(x = all.exons,
                             reference.annotation = Conrad.hg19.common.CNVs,
                             min.overlap = 0.5,
                             column.name = 'Conrad.hg19')
  all.exons <- AnnotateExtra(x = all.exons,
                             reference.annotation = exons.hg19.GRanges,
                             min.overlap = 0.0001,
                             column.name = 'exons.hg19')
  sample_name <- gsub('.bam','',bam_fn[j])
  output.file <- paste(out_path,'Exome_',sample_name, '.txt', sep = '')
  write.table(file = output.file, x = all.exons@CNV.calls, row.names = FALSE, quote = F)
}
