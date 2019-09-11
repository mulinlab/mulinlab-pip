# HiC-Pro

## Introduction

Hi-C data processing pipeline using HiC-Pro. 

## Applied

In practice, HiC-Pro was successfully applied to many data-sets including dilution Hi-C, in situ Hi-C, DNase Hi-C, Micro-C, capture-C, capture Hi-C or HiChip data.



## Require Software

The HiC-Pro pipeline requires the following dependencies :

+ The [bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) mapper
+ Python (>2.7) with *pysam (>=0.8.3)*, *bx-python(>=0.5.0)*, *numpy(>=1.8.2)*, and *scipy(>=0.15.1)* libraries.
  **Note that the current version does not support python 3**
+ R with the *RColorBrewer* and *ggplot2 (>2.2.1)* packages
+ g++ compiler
+ samtools (>1.1)
+ homer

## Install (in a dependent environment)

### Create a new environment

```shell
$ conda create -n py2 python=2.7
$ source activate py2
```

### Dependencies install

``` shell
$ conda install bowtie2
$ conda install python=2.7
$ conda install pysam
$ conda install bx-python
$ conda install numpy
$ conda install scipy 
$ conda install R
$ conda install r-ggplot2
$ conda install r-rcolorbrewer
$ conda install samtools
$ conda install homer

```

### HiC-Pro install

```shell
$ wget https://github.com/zhengzhanye/HiC-Pro/archive/master.zip
$ unzip master.zip
$ cd HiC-Pro-master
Edit configure-install.txt (if dependencies install successful,you only need manually defined the path to  'installation folder'; else you need edit the config-install.txt file and manually defined the paths to dependencies.)
$ make configure
$ make install
```

## Annotation Files

+ **A table file** of chromosomes' size.

  ```shell
  $ mkdir 00_hg19
  $ cd 00_hg19
  $ wget https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
  $ gunzip hg19.fa.gz
  $ http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes
  $ head -n 24 hg19.chrom.sizes | sort -V > ./hg19_size.txt
  ```

  

+ **A BED file** of the restriction fragments after digestion.This file **depends both of the restriction enzyme and the reference genome**. 

  ```
     chr1   0       16007   HIC_chr1_1    0   +
     chr1   16007   24571   HIC_chr1_2    0   +
     chr1   24571   27981   HIC_chr1_3    0   +
     chr1   27981   30429   HIC_chr1_4    0   +
     chr1   30429   32153   HIC_chr1_5    0   +
     chr1   32153   32774   HIC_chr1_6    0   +
     chr1   32774   37752   HIC_chr1_7    0   +
     chr1   37752   38369   HIC_chr1_8    0   +
     chr1   38369   38791   HIC_chr1_9    0   +
     chr1   38791   39255   HIC_chr1_10   0   +
     (...)
  ```

  **NOTE:** HindIII_resfrag_hg19.bed and HindIII_resfrag_mm10.bed has been provides in annotation dir. 

  ```shell
  ## For example：生成MboI 限制性内切酶 bed 文件，参考基因组hg19
  ## -r 指定酶切位点 （）
  ## -o 指定输出文件名称
  $ $PATH_of_hic/HiC-Pro_2.11.1/bin/utils/digest_genome.py -r ^GATC -o hg19_mobi.bed /$path_of_hg19/hg19.fa
  ```

  

+ **The bowtie2 indexes**.

  ```shell
  $ cd 00_hg19
  $ mkdir bowtie2
  $ bowtie2-build --threads 30 -f /hg19.fa ./bowtie2/hg19
  ```

  

## Usage

1. uniform data formate

   ```shell
   $ cd bin
   $ perl 01.0_pre4hicpro.pl
   ```

   detail information see 01.0_pre4hicpro.pl.

2. run hic-pro

   ```shell
   $ bash 01.1_hicpro.sh
   ```

   **NOTE：** 需要修改 .sh 中的HiC-Pro的路径，以及修改  $fcfg指代的cfg 文件中的路径。

3. bam to sam

   ```shell
   $ bash 02.0_bam2sam.sh 
   ```

4. homer call loop

   ```shell
   $ bash 03.0_HOME.sh
   ```

5. Deactivate environment

   ```shell
   $ source deactivate py2
   ```

   

## Troubleshooting

1. 文件太大时，sort时会产生很多临时文件，系统一直处于写的状态，此时就 会报错（samtools sort: fail to open      "tmp/H1-hESC_DpnII_inSitu_1_hg19.1020.bam": Too many open files）

   method:

   $path/HiC-Pro_2.11.1/scripts/bowtie_combine.sh 文件中sort 命令（## Sort merge file.版块）在sort -@ 中间加-m 10G 变成 sort -m 10G -@



## Reference 

https://github.com/nservant/HiC-Pro

http://bowtie-bio.sourceforge.net/bowtie2/index.shtml