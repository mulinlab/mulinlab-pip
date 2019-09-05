# Common CNV

[TOC]

## Description

Call copy number variants (CNVs) from targeted sequence data, typically exome sequencing experiments using R package **ExomeDepth**

## Install and configure

#### Install

```shell
# add bioconda channel
# conda config --add channels bioconda
# create a new  enviornment
$ conda create -n call_CNV
# To activate this environment, use
$ conda activate call_CNV
# install R and packages
$ conda install r-base
$ conda install -c bioconda r-exomedepth
$ conda install -c bioconda bioconductor-genomicranges
```

I uesd **ExomeDepth(1.1.11)** in this pipeline.

####  Inptut file

ExomeDepth requires at least 3 samples in BAM format as input, which should be sorted and with the index.

I use the chr1 fragment of three BAM files as the sample data ( `sample1.bam`, `sample2.bam`, `sample3.bam`).

#### Output file

* `ExomeCount_*.csv`: CSV file for exons count;

* ` Exome_*`: TSV files for CNV discovery.

#### Configure

There are some rows in **/bin/call_CNV.R** must be checked/configured:

- `task_na='test' `（Row 5）: Change `task`  to the name of your task.
- `am_path <- '../input/'`(Row 6)：Change `../input/` to the real input directory.
- `out_path <- '../output/'`（Row 7）：Change `../output/` to the real output directory.
- `fasta <- '~/ref_v37/human_g1k_v37.fasta`（Row 8）：Change  `~/ref_v37/human_g1k_v37.fasta` to the real reference FASTA file.

#### Run pipeline

```shell
$ cd bin/
$ Rscript call_CNV.R
```

## Main Steps

1. Create count data from BAM files
2. Build the most appropriate reference set
3. CNV calling

## Reference

- https://github.com/vplagnol/ExomeDepth

-  https://cran.r-project.org/web/packages/ExomeDepth/

