# MP_preSeq_FastQC

## Description
Quality control for NGS reads using FastQC

## Install and configure
`conda` is used to configure the pipeline environment.
```shell
# The conda environment can be named here
NID="pipeline_QC"
# Create a new environment
conda create -n $NID
# Activate the environment to install softwares
source activate $NID
conda install fastqc
# Deactivate it after finish installation
source deactivate $NID
```

## Input files
NGS reads either SE or PE in `FASTQ` format with or without `.gz` suffix, such as (take the `NA12878` as the sample ID for the example):

* SE reads: `NA12878.fq, NA12878.fq.gz` ; `NA12878.fastq`, `NA12878.fastq.gz`
* PE reads: `NA12878_1.fq`,  `NA12878_2.fq`;  `NA12878_1.fq.gz`,  `NA12878_2.fq.gz`;  `NA12878_1.fastq`,  `NA12878_2.fastq`;  `NA12878_1.fastq.gz`,  `NA12878_2.fastq.gz`

## Usage synopsis
### Main usage
```shell
# Before working, the pipeline environemnt should be activated
source activate $NID
bash fastqc.sh $in $out $cpus
source deactivate $NID
```
### Parameters explanation
1. `$in`: 
   * input folder containing FASTQ files, or
   * input FASTQ files
2. `$out`: output folder
3. `$cpus`: threads to use

## Output files

Two files will be output for each sample (take the `NA12878` as the sample ID for the example):

1. `NA12878_fastqc.html`: the main output for view
2. `NA12878_fastqc.zip`: the file can be used for script parser

## Key notes
### QC

Every parts should be checked in the `.html` file, especially:

1. `Basic Statistics`: Encoding, Total sequences, Sequence length
2. `Per base sequence quality`
3. `Per sequence quality scores`
4. `Sequence Length Distribution`
5. `Adapter Content`

### Tricks

`FastQC` set a thread for each file, so it has no real effect if the threads are set to an integer larger than file number.

### FAQ
### Others

`Encoding` in `Basic Statistics` should be checked especially for **old** NGS data.

## Usage example

All input and output files are stored in `test_data/pipeline_QC`.

### Inputs

* `NA12878_chr1_2Mb.fastq.gz`: FASTQ Gzip file  for SE reads 

### Run pipeline
```shell
source activate $NID
# make sure you are in the right working directory
bash fastqc.sh test_data/pipeline_QCNA12878_chr1_2Mb.fastq.gz test_data/pipeline_QC/output 1
source deactivate $NID
```

### Outputs
* `NA12878_chr1_2Mb_fastqc.html`: main output in HTML format

* `NA12878_chr1_2Mb_fastqc.zip`: a zipped folder contain all data you will need

  * `summary.txt` is a brief summary
  * `fastqc_data.txt` is the result in text format
  * `fastqc_report.html` is same to the main HTML output

  

## Reference

* [FastQC: A quality control tool for high throughput sequence data.](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* [Using FastQC to check the quality of high throughput sequence (YouTube)](https://www.youtube.com/watch?v=bz93ReOv87Y)
* [FastQC documentation](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/)
* [FastQC (GitHub)](https://github.com/s-andrews/FastQC)
* [利用fastqc检测原始序列的质量](https://www.jianshu.com/p/a1eb03d63083)
* [20160410 测序分析——使用 FastQC 做质控](https://zhuanlan.zhihu.com/p/20731723)
* [用FastQC检查二代测序原始数据的质量](https://www.cnblogs.com/yqsun/p/5821917.html)

## Author
Yi Xianfu (yixfbio AT gmail DOT com)

## License
GPL v3 or later