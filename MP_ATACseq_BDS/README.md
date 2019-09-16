# ATAC-seq

## Introduction

ATAC-seq or DNase-seq data processing pipeline.

## Require Software

+ Java (have been installed)
+ Conda  **( ! ! ! NOTE: Conda version is 4.5.12)**
+ bds (BigDataScript)
+ For python2 (python 2.x >= 2.7) and R-3.x, [requirements.txt](https://github.com/kundajelab/atac_dnase_pipelines/blob/master/requirements.txt) (package version)
+ For python3, [requirements_py3.txt](https://github.com/kundajelab/atac_dnase_pipelines/blob/master/requirements_py3.txt) (package version)

## Installation

### Conda （current version 4.5.12）

#### Download and install

```shell
$ cd $HOME
$ wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
$ bash Miniconda3-latest-Linux-x86_64.sh
```

Answer `yes` for the final question. If you choose `no`, you need to manually add Miniconda3 to your `$HOME/.bashrc`.

```shell
Do you wish the installer to prepend the Miniconda3 install location
to PATH in your /your/home/.bashrc ? [yes|no]
[no] >>> yes
```

Run `source ~/.bashrc` after install.

Run `conda -V`  to check conda version. 

if you conda version high than current version (4.5.12), you can reduce version use `conda install conda=4.5.12`	

#### Add channels   (**IMPORTANT** )

```shell 
$ conda config --add channels defaults
$ conda config --add channels conda-forge
$ conda config --add channels bioconda
$ conda config --add channels TUNA/anaconda/pkgs/main
$ conda config --add channels TUNA/anaconda/pkgs/free
$ conda config --add channels TUNA/anaconda/cloud/conda-forge/
```

## BigDataScript

**! ! ! NOTE : If you have install ChIP-seq pipeline, skip this step !**

Install BigDataScript v0.99999e ([forked](https://github.com/leepc12/BigDataScript)) on your system. The original [BDS v0.99999e](https://github.com/pcingola/BigDataScript) does not work correctly with the pipeline (see [PR #142](https://github.com/pcingola/BigDataScript/pull/142) and [issue #131](https://github.com/pcingola/BigDataScript/issues/131)).

```
$ wget https://github.com/leepc12/BigDataScript/blob/master/distro/bds_Linux.tgz?raw=true -O bds_Linux.tgz
$ mv bds_Linux.tgz $HOME && cd $HOME && tar zxvf bds_Linux.tgz
```

Add `export PATH=$PATH:$HOME/.bds` to your `$HOME/.bashrc`. If Java memory occurs, add `export _JAVA_OPTIONS="-Xms256M -Xmx728M -XX:ParallelGCThreads=1"` too.

## Pipeline

Get ATAC-seq pipeline.

```shell
$ wget https://github.com/zhengzhanye/atac_dnase_pipelines/archive/master.zip
$ unzip master.zip
```

## Dependencies

Install software dependencies automatically. It will create two conda environments (bds_atac and bds_atac_py3) under your conda.

```shell
$ cd atac_dnase_pipelines
$ bash install_dependencies.sh
```

**NOTE :** If `install_dependencies.sh` fails, run `./uninstall_dependencies.sh`, fix problems and then try `bash install_dependencies.sh` again.

## Genome data

Install genome data for a specific genome **[GENOME]. Currently hg19, mm9, hg38 and mm10 are available**. Specify a **directory [DATA_DIR] to download genome data**. A species file generated on `[DATA_DIR]` will be automatically added to your `./default.env` so that the pipeline knows that you have installed genome data using `install_genome_data.sh`. **If you want to install multiple genomes make sure that you use the same directory [DATA_DIR] for them.** Each genome data will be installed on `[DATA_DIR]/[GENOME]`. If you use other BDS pipelines, it is recommended to use the same directory `[DATA_DIR]`to save disk space.

**NOTE:** `install_genome_data.sh` can take longer than an hour for downloading data and building index. DO NOT run the script on a login node, use `qlogin` for SGE and `srun --pty bash` for SLURM.

```shell
$ cd $PATH/ChIP-seq/TF_chipseq_pipeline 
$ bash install_genome_data.sh [GENOME] [DATA_DIR]
```

## Usage

#### Fastq QC

+ Whenever you want to process fastq file, the first one to do is check the quality of fastq file.

  ```shell
  $ fastqc test_1.fastq.gz -o ./
  ```

+ If quality is good then you can run the ChIP-seq pipeline, otherwise you need processed fastq data to clean data. (For example : adapter error, bar code error) **(Note : cutadapter or trim_galore can be used to covert raw data to clean data)**.

#### Run pipeline with a configure file

```shell
$ bds $PATH/atac_dnase_pipelines/atac.bds [congure_file]
### $PATH need to replace to you own path of atac_dnase_pipelines
```

Parameters from a configure file:

```
### for pair-end fastq (no replicate)
type = atac-seq
species = [GENOME]
nth = [NUM_THREADS]
pe = true
enable_idr = true
fastq1_1 = "...."
fastq1_2 = "...."
out_dir = [path of output result directory]
#### NOTE : if you want to process DNase-seq data ,you need to revise type = dnase-seq
```

```
### for dignal-end fastq (no replicate)
type = atac-seq
species = [GENOME]
nth = [NUM_THREADS]
se = true
enable_idr = true
fastq1 = "...."
out_dir = [path of output result directory]
#### NOTE : if you want to process DNase-seq data ,you need to revise type = dnase-seq
```

More detailed information see below:

#### Input data type

There are four data types; `fastq`, `bam`, `filt_bam` and `tag` .

+ For multiple replicates (PE), specify fastqs with `-fastq[REP_ID]_[PAIR_ID]`.
+ For multiple replicates (SE), specify fastqs with `-fastq[REP_ID]`: 

```
## for pair-end fastq (with replicate)
type = atac-seq
species = [GENOME]
nth = [NUM_THREADS]
pe = true
enable_idr = true
fastq1_1 = "...."
fastq1_2 = "...."
fastq2_1 = "...."
fastq2_2 = "...."
out_dir = [path of output result directory]
#### NOTE : if you want to process DNase-seq data ,you need to revise type = dnase-seq
```

```
## for signal-end fastq (with replicate)
### for dignal-end fastq (no replicate)
type = atac-seq
species = [GENOME]
nth = [NUM_THREADS]
se = true
enable_idr = true
fastq1 = "...."
fastq2 = "...."
out_dir = [path of output result directory]
#### NOTE : if you want to process DNase-seq data ,you need to revise type = dnase-seq
```

## Output directory structure and file name

```
out                               # root dir. of outputs
│
├ *report.html                    #  HTML report
├ *tracks.json                    #  Tracks datahub (JSON) for WashU browser
├ ENCODE_summary.json             #  Metadata of all datafiles and QC results
│
├ align                           #  mapped alignments
│ ├ rep1                          #   for true replicate 1 
│ │ ├ *.trim.fastq.gz             #    adapter-trimmed fastq
│ │ ├ *.bam                       #    raw bam
│ │ ├ *.nodup.bam (E)             #    filtered and deduped bam
│ │ ├ *.tagAlign.gz               #    tagAlign (bed6) generated from filtered bam
│ │ ├ *.tn5.tagAlign.gz           #    TN5 shifted tagAlign for ATAC pipeline (not for DNase pipeline)
│ │ └ *.*M.tagAlign.gz            #    subsampled tagAlign for cross-corr. analysis
│ ├ rep2                          #   for true repilicate 2
│ ...
│ ├ pooled_rep                    #   for pooled replicate
│ ├ pseudo_reps                   #   for self pseudo replicates
│ │ ├ rep1                        #    for replicate 1
│ │ │ ├ pr1                       #     for self pseudo replicate 1 of replicate 1
│ │ │ ├ pr2                       #     for self pseudo replicate 2 of replicate 1
│ │ ├ rep2                        #    for repilicate 2
│ │ ...                           
│ └ pooled_pseudo_reps            #   for pooled pseudo replicates
│   ├ ppr1                        #    for pooled pseudo replicate 1 (rep1-pr1 + rep2-pr1 + ...)
│   └ ppr2                        #    for pooled pseudo replicate 2 (rep1-pr2 + rep2-pr2 + ...)
│
├ peak                             #  peaks called
│ └ macs2                          #   peaks generated by MACS2
│   ├ rep1                         #    for replicate 1
│   │ ├ *.narrowPeak.gz            #     narrowPeak (p-val threshold = 0.01)
│   │ ├ *.filt.narrowPeak.gz (E)   #     blacklist filtered narrowPeak 
│   │ ├ *.narrowPeak.bb (E)        #     narrowPeak bigBed
│   │ ├ *.narrowPeak.hammock.gz    #     narrowPeak track for WashU browser
│   │ ├ *.pval0.1.narrowPeak.gz    #     narrowPeak (p-val threshold = 0.1)
│   │ └ *.pval0.1.*K.narrowPeak.gz #     narrowPeak (p-val threshold = 0.1) with top *K peaks
│   ├ rep2                         #    for replicate 2
│   ...
│   ├ pseudo_reps                          #   for self pseudo replicates
│   ├ pooled_pseudo_reps                   #   for pooled pseudo replicates
│   ├ overlap                              #   naive-overlapped peaks
│   │ ├ *.naive_overlap.narrowPeak.gz      #     naive-overlapped peak
│   │ └ *.naive_overlap.filt.narrowPeak.gz #     naive-overlapped peak after blacklist filtering
│   └ idr                           #   IDR thresholded peaks
│     ├ true_reps                   #    for replicate 1
│     │ ├ *.narrowPeak.gz           #     IDR thresholded narrowPeak
│     │ ├ *.filt.narrowPeak.gz (E)  #     IDR thresholded narrowPeak (blacklist filtered)
│     │ └ *.12-col.bed.gz           #     IDR thresholded narrowPeak track for WashU browser
│     ├ pseudo_reps                 #    for self pseudo replicates
│     │ ├ rep1                      #    for replicate 1
│     │ ...
│     ├ optimal_set                 #    optimal IDR thresholded peaks
│     │ └ *.filt.narrowPeak.gz (E)  #     IDR thresholded narrowPeak (blacklist filtered)
│     ├ conservative_set            #    optimal IDR thresholded peaks
│     │ └ *.filt.narrowPeak.gz (E)  #     IDR thresholded narrowPeak (blacklist filtered)
│     ├ pseudo_reps                 #    for self pseudo replicates
│     └ pooled_pseudo_reps          #    for pooled pseudo replicate
│
│   
│ 
├ qc                              #  QC logs
│ ├ *IDR_final.qc                 #   Final IDR QC
│ ├ rep1                          #   for true replicate 1
│ │ ├ *.align.log                 #    Bowtie2 mapping stat log
│ │ ├ *.dup.qc                    #    Picard (or sambamba) MarkDuplicate QC log
│ │ ├ *.pbc.qc                    #    PBC QC
│ │ ├ *.nodup.flagstat.qc         #    Flagstat QC for filtered bam
│ │ ├ *M.cc.qc                    #    Cross-correlation analysis score for tagAlign
│ │ ├ *M.cc.plot.pdf/png          #    Cross-correlation analysis plot for tagAlign
│ │ └ *_qc.html/txt               #    ATAQC report
│ ...
│
├ signal                          #  signal tracks
│ ├ macs2                         #   signal tracks generated by MACS2
│ │ ├ rep1                        #    for true replicate 1 
│ │ │ ├ *.pval.signal.bigwig (E)  #     signal track for p-val
│ │ │ └ *.fc.signal.bigwig   (E)  #     signal track for fold change
│ ...
│ └ pooled_rep                    #   for pooled replicate
│ 
├ report                          # files for HTML report
└ meta                            # text files containing md5sum of output files and other metadata
```

## ATAC-seq QC

### Library Complexity

- NRF=Distinct/Total (NRF (Non-Redundant Fraction) : Number of distinct uniquely mapping reads(i.e. after removing duplicates) /Total number of reads)

- PBC1=OnePair/Distinct (One Read Pairs : number of genomic locations where exactly one read maps uniquely) 

- PBC2=OnePair/TwoPair (Two Read Pairs : number of genomic locations where exactly two read maps uniquely )

  | PBC1           | PBC2       | Bottlenecking level | NRF           | Complexity | Flag colors |
  | -------------- | ---------- | ------------------- | ------------- | ---------- | ----------- |
  | <0.7           | <1         | Severe              | <0.7          | Concerning | Orange      |
  | 0.7<=PBC1<=0.9 | 1<=PBC2<=3 | Moderate            | 0.7<=NFR<=0.9 | Acceptable | Yellow      |
  | >0.9           | >3         | None                | >0.9          | Ideal      | None        |

### TSS enrichment score 

+ The TSS enrichment calculation is a singal to noise calculation.

+ The TSS enrichment score  is association with reference genome.

  |            | hg19 | hg38 | mm9  | mm10  |
  | ---------- | ---- | ---- | ---- | ----- |
  | Concerning | <6   | <5   | <5   | <10   |
  | Acceptable | 6-10 | 5-7  | 5-7  | 10-15 |
  | Ideal      | >10  | >7   | >7   | >1    |

## Reference

pipeline https://github.com/kundajelab/atac_dnase_pipelines

