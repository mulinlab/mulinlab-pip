# MP_RNAseq_RNACocktail

## Description

RNA-seq analysis using RNACocktail, from sequencing reads to differential expression genes, including several plots

## Install and configure

### Install RNACocktail

Pull the docker image using `docker pull` command, make sure:

1. `docker` has been installed on the system.
2. Permission is needed, so `sudo` should be used.

```shell
# sudo docker pull marghoob/rnacocktail
```

### Prepare environment

`conda` is used to prepare the pipeline environment.

```shell
# The conda environment can be named here
NID="RNACocktail"
# Create a new environment
conda create -n $NID
# Activate the environment to install softwares
conda activate $NID
conda install samtools r-tidyverse r-ggrepel r-ggfortify r-rcolorbrewer r-pheatmap
# Deactivate it after finish installation
conda deactivate
```

### Prepare reference

Reference genome sequence and gene annotation are downloaded from [GENCODE](https://www.gencodegenes.org/).

```shell
bash prepare_reference.sh $wd $species
```
* `$wd`: work directory, the folder path where the reference will be saved to
* `$species`: `human` or `mouse`
* `species.conf` and `others.conf` can be configured for specific reference.

## Input files

### Reads files

NGS PE reads in FASTQ format with suffix of  `_1.fastq.gz` and `_2.fastq.gz`. Prefix is the sample ID.

### Configure files

* `samples.conf`: The column one is the sample group ID; column two is sample IDs which is seperated by `,`(comma, *without space*).
* `diff.conf`: The column one is the control group (base group), column two is the case group. the group IDs should be same as IDs in `samples.conf`. More than one pair comparison can be added. The column two will be used as the baseline.
* `others.conf`: set CPU numbers and others. The column one (`key`) should not be changed!

## Usage synopsis

```shell
# 1. run RNACocktail
# step1: align and reconstruct with HISAT2; quantify with Salmon 
nohup bash bin/01.1_align.sh $path_ref $path_input $path_output >align.log 2>&1 &
# step2: differential expression analysis
nohup bash bin/01.2_diff.sh $path_ref $path_output >diff.log 2>&1 &
# You can run them in on command
# nohup bash bin/01_run_RNACocktail.sh $path_ref $path_input $path_output >RNACocktail.log 2>&1 & 
# 2. gather expression data
bash bin/02_gather_expression.sh $path_ref $path_output
# 3. gather differentail expression gene
bash bin/03_gather_deg.sh $path_ref $path_output
# 4. plot figures based on expression data
bash bin/04_plot_expression.sh $path_output
# 5. plot figures based on DEG data
bash bin/05_plot_deg.sh $path_output
```

* `$path_ref`: folder path to reference
* `$path_input`: folder path to reads
* `$path_output`: main work directory, folder path to save output

## Output files

There are 6 folders will be created, which can be grouped to 3 groups.

1. RNACocktail folders
   	* `RNACocktail_work`: the work folder when RNACocktail was running, which contains all files including temporary and log files.
    * `RNACocktail_out`: the result folder for RNACocktail which should be used mainly.
2. data folders: these two folders are generated from RNACocktail folders
   	* `expression`: the expression data folder
    * `deg`: the DEG data folder
3. figure folders: these two folders are generated from data folders
   	* `plot_expression`: figures which display the expression data, including samples clustering and sample PCA.
    * `plot_deg`: figures which display the differential expression genes' data, including valcano and heatmap, only the top 100 genes are labeled or plotted.

## Key notes

### Parameters explanation

* The cutoff used for filtering differential expression genes (DEG) can be changed in `bin/03.3_get_deg_list.pl`, `bin/05.1_volcano.R` and `bin/05.2_heatmap.R`. The default cutoff used here is:
  	* fold change >=2, that is `abs(log2FC)` >=1; **AND**
  	* adjust-p value <=0.05.

### Others

* To use docker without `permission denied`, the user should be added to the `docker` group using `sudo usermod -aG docker $USER`. Then logout and login again.
* Reference preparing may take **hours** (>0.5h)!

## Usage example

### Inputs

* They are two groups (`case` vs. `ctrl`). Each group has three replicates (`rep1`, `rep2` and `rep3`). For PE reads, there are two files for each replicate (`_1` and `_2`). 

* Make sure each file has the `.fastq.gz` suffix.

### Run pipeline

```shell
nohup bash bin/01.1_align.sh reference/GRCm38_vM22 test_data/input test_data/output >align.log 2>&1 &
nohup bash bin/01.2_diff.sh reference/GRCm38_vM22 test_data/output >diff.log 2>&1 &
bash bin/02_gather_expression.sh reference/GRCm38_vM22 test_data/output
bash bin/03_gather_deg.sh reference/GRCm38_vM22 test_data/output
bash bin/04_plot_expression.sh test_data/output
bash bin/05_plot_deg.sh test_data/output
```

### Outputs

* RNACocktail's output are saved in `RNACocktail_work` and `RNACocktail_out` folders.
* expression and DEG data are saved in `expression` and `deg` folders.
* The figures including QC are saved in `plot_expression`  and `plot_deg` folders.

## Reference

* [RNACocktail (Homepage)](https://bioinform.github.io/rnacocktail/)
* [RNACocktail (GitHub)](https://github.com/bioinform/rnacocktail)
* [RNACocktail (Paper)](https://www.nature.com/articles/s41467-017-00050-4)
* [RNACocktail (docker)](https://hub.docker.com/r/marghoob/rnacocktail)

## ToDo

1. Change the hard cutoff for DEG filtering to user's configuration.

## Author

Yi Xianfu (yixfbio AT gmail DOT com)

## License

GPL v3 or later