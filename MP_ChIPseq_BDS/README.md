# ChIP-seq

## Introduction

Transcription Factor and Histone ChIP-seq processing pipeline using BDS (BigDataScript).

## Require Software

+ Java (have been installed)
+ Conda
+ bds (BigDataScript)
+ samtools

## Installation

### Conda 

```shell
$ cd $HOME
$ wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
$ bash Anaconda3-2019.07-Linux-x86_64.sh
```

Answer `yes` for the final question. If you choose `no` , you need to manually add Anaconda3 to you `$HOME/.bashrc`.

```shell
Do you wish the installer to prepend the Anaconda3 install location
to PATH in your /your/home/.bashrc ? [yes|no]
[no] >>> yes
```

Run `souce ~/.bashrc` after installation.

### BigDataScript

```shell
$ cd $HOME
$ wget https://github.com/leepc12/BigDataScript/blob/master/distro/bds_Linux.tgz?raw=true -O bds_Linux.tgz
$ tar zxvf bds_Linux.tgz
```

### Pipeline

Get ChIP-Seq pipeline.

```shell
$ cd $PATH/ChIP-seq/package
$ tar zxvf TF_chipseq_pipeline.tar.gz
$ mv TF_chipseq_pipeline ../ && cd ../
```

### Dependencies

Install software dependencies automatically. It will create two conda environments (aquas_chipseq and aquas_chipseq_py3) under your conda.

```shell
$ cd $PATH/ChIP-seq/TF_chipseq_pipeline
$ bash install_dependencies.sh
```

If `install_dependencies.sh` fails, run `./uninstall_dependencies.sh`, fix problems and then try `bash install_dependencies.sh` again.

### Genome data

Install genome data for a specific genome **`[GENOME]`. Currently `hg19`, `mm9`, `hg38` and `mm10` are available**. Specify a **directory `[DATA_DIR]` to download genome data**. A species file generated on `[DATA_DIR]` will be automatically added to your `./default.env` so that the pipeline knows that you have installed genome data using `install_genome_data.sh`. **If you want to install multiple genomes make sure that you use the same directory `[DATA_DIR]` for them.** Each genome data will be installed on `[DATA_DIR]/[GENOME]`. If you use other BDS pipelines, it is recommended to use the same directory `[DATA_DIR]`to save disk space.

**NOTE:** `install_genome_data.sh` can take longer than an hour for downloading data and building index. DO NOT run the script on a login node, use `qlogin` for SGE and `srun --pty bash` for SLURM.

```shell
$ cd $PATH/ChIP-seq/TF_chipseq_pipeline 
$ bash install_genome_data.sh [GENOME] [DATA_DIR]
```

## Usage

There are two ways to define parameters for ChIP-Seq pipelines. 1. Parameters from command line arguments; 2.Parameters from a configuration file. We recommend using configure file to run pipeline.

### Fastq QC

- Whenever you want to process fastq file, the first one to do is check the quality of fastq file.

  ```shell
  fastqc c1.clean_1.fastq.gz -o ./
  ```

- If quality is good then you can run the ChIP-seq pipeline, otherwise you need processed fastq data to clean data. (For example : adapter error, bar code error) **(Note : cutadapter or trim_galore can be used to covert raw data to clean data)**.

### Run pipeline with a configure file

```shell
$ python $PATH/ChIP-seq/TF_chipseq_pipeline/chipseq.py [CONF_JSON_FILE]
```

Parameters from a configuration file:

Choose `[CHIPSEQ_TYPE]` between `TF`  and `histone`.

```
## for pair-end fastq (no replicate)
{
  "type" : "[CHIPSEQ_TYPE]",
  "species" : [GENOME],
  "nth" : [NUM_THREADS],
  "pe" : true,
  "fastq1_1" : "...",
  "fastq1_2" : "...",
  "ctl_fastq1_1" : "...",
  "ctl_fastq1_2" : "...",
  "out_dir" : "[path of output result directory]"
}
```

```
## for signal-end fastq (no replicate)
{
  "type" : "[CHIPSEQ_TYPE]",
  "species" : [GENOME],
  "nth" : [NUM_THREADS],
  "se" : true,
  "fastq1" : "...",
  "ctl_fastq1" : "...",
  "out_dir" : "[path of output result directory]"
}
```

Above are base parameters, see the detailed information below.

### Input data type

There are five data types; `fastq`, `bam`, `filt_bam`, `tag` and `peak`.

- For treat. replicates: define data path with `-[DATA_TYPE][REPLICATE_ID]`.
- For contols: define data path with `-ctl_[DATA_TYPE][CONTROL_ID]`.

### SE/PE

For fastqs:

- For treat. replicates:
  - Define data path as -fastq[REPLICATE_ID], then it's SE (single ended).
  - Define data path as -fastq[REPLICATE_ID]_[PAIRING_ID], then it's PE.
- For controls:
  - Define data path as -ctl_fastq[REPLICATE_ID], it's SE.
  - Define data path as -ctl_fastq[REPLICATE_ID]_[PAIRING_ID], it's PE.

``` 
## for pair-end fastq (with replicate)
{
  "type" : "[CHIPSEQ_TYPE]",
  "species" : [GENOME],
  "nth" : [NUM_THREADS],
  "pe" : true,
  "fastq1_1" : "...",
  "fastq1_2" : "...",
  "fastq2_1" : "...",
  "fastq2_2" : "...",
  "ctl_fastq1_1" : "...",
  "ctl_fastq1_2" : "...",
  "out_dir" : "[path of output result directory]"
}
```

```
## for signal-end fastq (with replicate)
{
  "type" : "[CHIPSEQ_TYPE]",
  "species" : [GENOME],
  "nth" : [NUM_THREADS],
  "se" : true,
  "fastq1" : "...",
  "fastq2" : "...",
  "ctl_fastq1" : "...",
  "out_dir" : "[path of output result directory]"
}
```

## Broad peak

**NOTE：** ChIP-Seq pipeline disabled gapped/broad peak generation because MACS2 has some flaws in its algorithm for them. (reference https://github.com/ENCODE-DCC/chip-seq-pipeline2/issues/30)

If you want **call broad peak**, only need to modify [chipseq.bds #line34](https://github.com/kundajelab/chipseq_pipeline/blob/master/chipseq.bds#L34) (true modify to false)

## Default parameter

+ idr thresh is 0.05	 （idr peak is only for tf）
+ P-value cutoff (macs2 callpeak)	: 0.01
+ spp for TF ChIP-seq and macs2 for Histone ChIP-seq 

## Output directory structure and file naming

```
out                               # root dir. of outputs
│
├ *report.html                    #  HTML report
├ *tracks.json                    #  Tracks datahub (JSON) for WashU browser
├ ENCODE_summary.json             #  Metadata of all datafiles and QC results
│
├ align                           #  mapped alignments
│ ├ rep1                          #   for true replicate 1 
│ │ ├ *.bam                       #    raw bam
│ │ ├ *.nodup.bam                 #    filtered and deduped bam
│ │ ├ *.tagAlign.gz               #    tagAlign (bed6) generated from filtered bam
│ │ ├ *.*M.tagAlign.gz            #    subsampled tagAlign for cross-corr. analysis
│ ├ rep2                          #   for true repilicate 2
│ ...
│ ├ ctl1                          #   for control 1
│ ...
│ ├ pooled_rep                    #   for pooled replicate
│ ├ pseudo_reps                   #   for self pseudo replicates
│ │ ├ rep1                        #    for replicate 1
│ │ │ ├ pr1                       #     for self pseudo replicate 1 of replicate 1
│ │ │ └ pr2                       #     for self pseudo replicate 2 of replicate 1
│ │ ├ rep2                        #    for repilicate 2
│ │ ...                           
│ └ pooled_pseudo_reps            #   for pooled pseudo replicates
│   ├ ppr1                        #    for pooled pseudo replicate 1 (rep1-pr1 + rep2-pr1 + ...)
│   └ ppr2                        #    for pooled pseudo replicate 2 (rep1-pr2 + rep2-pr2 + ...)
│
├ peak                            #  peaks called
│ ├ macs2                         #   peaks generated by MACS2
│ │ ├ rep1                        #    for replicate 1
│ │ │ ├ *.narrowPeak.gz           #     narrowPeak
│ │ │ ├ *.gappedPeak.gz           #     gappedPeak
│ │ │ ├ *.filt.narrowPeak.gz      #     blacklist filtered narrowPeak 
│ │ │ ├ *.filt.gappedPeak.gz      #     blacklist filtered gappedPeak
│ │ ├ rep2                        #    for replicate 2
│ │ ...
│ │ ├ pseudo_reps                 #   for self pseudo replicates
│ │ └ pooled_pseudo_reps          #   for pooled pseudo replicates
│ │
│ ├ spp                           #   peaks generated by SPP
│ │ ├ rep1                        #    for replicate 1
│ │ │ ├ *.regionPeak.gz           #     regionPeak (narrowPeak format) generated from SPP
│ │ │ ├ *.filt.regionPeak.gz      #     blacklist filtered narrowPeak 
│ │ ├ rep2                        #    for replicate 2
│ │ ...
│ │ ├ pseudo_reps                 #   for self pseudo replicates
│ │ └ pooled_pseudo_reps          #   for pooled pseudo replicates
│ │
│ └ idr                           #   IDR thresholded peaks (using peaks from SPP)
│   ├ true_reps                   #    for replicate 1
│   │ ├ *.narrowPeak.gz           #     IDR thresholded narrowPeak
│   │ ├ *.filt.narrowPeak.gz      #     IDR thresholded narrowPeak (blacklist filtered)
│   │ └ *.12-col.bed.gz           #     IDR thresholded narrowPeak track for WashU browser
│   ├ pseudo_reps                 #    for self pseudo replicates
│   │ ├ rep1                      #    for replicate 1
│   │ ...
│   ├ optimal_set                 #    optimal IDR thresholded peaks
│   │ └ *.filt.narrowPeak.gz      #     IDR thresholded narrowPeak (blacklist filtered)
│   ├ conservative_set            #    optimal IDR thresholded peaks
│   │ └ *.filt.narrowPeak.gz      #     IDR thresholded narrowPeak (blacklist filtered)
│   ├ pseudo_reps                 #    for self pseudo replicates
│   └ pooled_pseudo_reps          #    for pooled pseudo replicate
│
├ qc                              #  QC logs
│ ├ *IDR_final.qc                 #   Final IDR QC
│ ├ rep1                          #   for true replicate 1
│ │ ├ *.flagstat.qc               #    Flagstat QC for raw bam
│ │ ├ *.dup.qc                    #    Picard (or sambamba) MarkDuplicate QC log
│ │ ├ *.pbc.qc                    #    PBC QC
│ │ ├ *.nodup.flagstat.qc         #    Flagstat QC for filtered bam
│ │ ├ *M.cc.qc                    #    Cross-correlation analysis score for tagAlign
│ │ └ *M.cc.plot.pdf/png          #    Cross-correlation analysis plot for tagAlign
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
└ report                          # files for HTML report
```

## ChIP-seq  QC

### Library Complexity

+ NRF=Distinct/Total  (NRF (Non-Redundant Fraction) : Number of distinct uniquely mapping reads(i.e. after removing duplicates) /Total number of reads)

+ PBC1=OnePair/Distinct  (One Read Pairs :  number of genomic locations where exactly one read maps uniquely)
  PBC2=OnePair/TwoPair (Two Read Pairs : number of genomic locations where exactly two read maps uniquely )

  | PBC1          | PBC2       | Bottlenecking level | NRF          | Complexity | Flag colors |
  | ------------- | ---------- | ------------------- | ------------ | ---------- | ----------- |
  | <0.5          | <1         | Severe              | <0.5         | Concerning | Orange      |
  | 0.5<=PBC1<0.8 | 1<=PBC2<3  | Moderate            | 0.5<=NFR<0.8 | Acceptable | Yellow      |
  | 0.8<=PBC1<0.9 | 3<=PBC2<10 | Mild                | 0.8<=NFR<0.9 | Compliant  | None        |
  | >=0.9         | >=10       | None                | >0.9         | Ideal      | None        |

### Cross-correlation

+ A very useful ChIP-seq quality metric that is independent of peak calling is strand cross-correlation.
+ Strand cross-correlation is computed as the Pearson correlation between the positive and the negative strand profiles at different strand shift distances, k
+ **NSC (normalized strand coefficient)** : <1 (no enrichment) , <1.1 (are relatively low NSC scores).
+ **RSC (relative strand correlation)**: 0 (无信号)， >1 high enrichment 

## FPiR 

+ fraction of all mapped reads that fall into the called peak region
+ FPiR > 0.3, or > 0.2 (acceptable)

## Reference

pipeline https://github.com/kundajelab/chipseq_pipeline#aquas-pipeline

broad peak https://github.com/ENCODE-DCC/chip-seq-pipeline2/issues/30

https://www.jianshu.com/p/0d3515420170

https://www.plob.org/article/10866.html



## Troubshooting

1. ImportError: Something is wrong with the numpy installation. While importing we detected an older version of numpy in ['/g/zhanye/anaconda3/envs/aquas_chipseq/lib/python2.7/site-packages/numpy']. One method of fixing this is to repeatedly uninstall numpy until none is found, then reinstall this version.

   method:

   ```shell
   $ source activate aquas_chipseq
   $ conda uninstall numpy
   $ conda install numpy
   $ source deactivate aquas_chipseq
   ```

2. plotFingerprint not found

   method:

   ```shell
   $ source activate aquas_chipseq
   $ pip install deeptools
   $ source deactivate aquas_chipseq
   ```

3. ImportError: numpy.core.multiarray failed to import

   method:

   ```shell
   $ pip install --upgrade numpy
   ```

   