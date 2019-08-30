# MP_4Cseq_4Cseqpipe

## Description
Mapping and analyzing 4C-seq experiments using 4Cseqpipe

## Install and configure
### Install
Just copy the template directory to your work directory.
```shell
dir_work="data/4Cseqpipe"
cp -R reference/pipeline_4Cseqpipe/template $dir_work
```
### Configure
There are two files must be checked/configured:
1. `rawdata/index.txt`: One sample per line.
	* `species_name`(Column 6): Change to the real species, `Mus_musculus` or `Homo_sapiens`.
	* `primer_seq`(Column 5): Change to the real primer.
	* `first/sec_cutter_name/seq`(Column 7-10): Change to the real data.
	* `bait_chromo/coord`(Column 13,14): Change to the real bait chromosome and coordinate.
	* `seq_len`(Column 15): Change to the real read length.
	* `raw_fname`(Column 16): Set the name, which will be saved in the `rawdata` folder.
	* Other columns have no big effect. `id`(Column 1) will be used as the experiment ID. `run, lane_no, exp`(Column 2-4) is just for your tailored experiment. `linearization_name/seq`(Column 11,12) can keep as "NA".
2. `4cseqpipe.conf`
	* `index=rawdata/index.txt`(First line): Make sure or change the `index.txt` file path.
	* `trackdb_root=mm9_trackdb`(Second line): Make sure or change the `trackdb_root` path.
	* `trackset_name=4c`(Third line): Change the name to your sample. **Pay attention please**, a same named folder will be created in the `trackdb_root/tracks` directory.

## Input files
NGS reads form 4C experiment in `FASTQ` format. PE reads can be concatenated to one single file, or used seperately.

## Usage synopsis
### Main usage
```shell
cd $dir_work
# 1. Convert FASTQ files to "raw" format
## $id: Corresponding to the "index.txt" file
## $fastq: Path to the FASTQ file
perl 4cseqpipe.pl -fastq2raw -ids $id -fastq_fn $fastq
# 2. Mapping valid 4C-Seq procucts to restriction fragments in the genome
perl 4cseqpipe.pl –map -ids $id
# 3. Normalizing and generating near-cis domainograms
## $start, $end: genomic range for computing normalized trend
## $res: size of window in basepairs (5000, 2000 or 1000 is used most)
## $fig: Output figure filename, which will be stored in `figures` folder.
perl 4cseqpipe.pl –nearcis -ids $id -calc_from $start -calc_to $end -stat_type median -trend_resolution $res -figure_fn $fig
# three steps in one: fastq2raw + map + nearcis
# perl 4cseqpipe.pl -dopipe [all parameters above]
```
### Parameters explanation
The detailed explanation and full parameters can be found on the [website](http://compgenomics.weizmann.ac.il/tanay/?page_id=367) or [manual](../../reference/pipeline_4Cseqpipe/4cseq_pipe_manual.pdf).

## Output files
The main output file is a figure in PNG format, which is stored in the `figures` folder.

## Key notes
### QC
### Tricks
* For PE reads, two files can be concatenated to one file. Besides, you can try to run this pipeline for each file, and choose the best result.
* If the pipeline terminate for no enough data, you can extent the genome range (controlled by `-calc_from` and `calc_to`) and try again.
* The parameter `-convert_qual` may should be set to `1` if the pipeline fail. *But what is its meaning?*
### FAQ
### Others
Before runing the pipeline, please contact the experimentalist to collect information required for the pipeline:
1. Primer sequence: Usually, the **reverse primier** is what you need.
2. Enzymes (and their [cut sites](http://rebase.neb.com/rebase/link_bionet))
3. Bait point coordiante: Check the coordinate system, convert it if necessary.

## Usage example
All input and output files are stored in `test_data/pipeline_4Cseqpipe`.
### Inputs
FASTQ files for two sample experiments performed using the alpha1 globin gene promoter as the viewpoint in mouse fetal liver and fetal brain (Van de Werken, Landan, *et. al.*, 2012):
* `alpha_FL.fastq`: experiment in fetal liver cells using the highly active alpha1 globin promoter as viewpoint
* `alpha_FB.fastq`: same viewpoint in a different tissue (fetal brain, in which the alpha1 globin gene is not active)
### Run pipeline
```shell
# Prepare the pipeline
dir_work="test_data/pipeline_4Cseqpipe/4Cseqpipe_for_test"
cp -R reference/pipeline_4Cseqpipe/template $dir_work
cd $dir_work
# Configure the pipeline
# 1. Change the `trackdb_root` in `4cseqpipe.conf` file as ``.
# Run the pipeline
## Case
perl 4cseqpipe.pl -fastq2raw -ids 1 -fastq_fn ../alpha_FL.fastq
perl 4cseqpipe.pl -map -ids 1
perl 4cseqpipe.pl -nearcis -calc_from 32000000 -calc_to 32300000 -stat_type median -trend_resolution 5000 -ids 1 -figure_fn alpha_FL.png
cp figures/alpha_FL.png ../output/
## Control
perl 4cseqpipe.pl -fastq2raw -ids 2 -fastq_fn ../alpha_FB.fastq
perl 4cseqpipe.pl -map -ids 2
perl 4cseqpipe.pl -nearcis -calc_from 32000000 -calc_to 32300000 -stat_type median -trend_resolution 5000 -ids 2 -figure_fn alpha_FB.png
cp figures/alpha_FB.png ../output/
```
### Outputs
* `alpha_FL.png`: The case output
* `alpha_FB.png`: The control output
* Other folders, such as `tables`, `stats`, may should be checked if necessary. Please reference the [website](http://compgenomics.weizmann.ac.il/tanay/?page_id=367) or [manual](../../reference/pipeline_4Cseqpipe/4cseq_pipe_manual.pdf) for more information.

## Reference
* [4Cseqpipe](http://compgenomics.weizmann.ac.il/tanay/?page_id=367)
* [Robust 4C-seq data analysis to screen for regulatory DNA interactions](https://www.ncbi.nlm.nih.gov/pubmed/22961246)

## Author
Yi Xianfu (yixfbio AT gmail DOT com)

## License
GPL v3 or later