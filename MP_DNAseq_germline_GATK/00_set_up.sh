#!/bin/bash

# GATK 4.1.3.0
wget -c https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip
unzip gatk-4.1.3.0.zip
rm gatk-4.1.3.0.zip
cd gatk-4.1.3.0
conda env create -f gatkcondaenv.yml

conda activate gatk

# samtools 1.9
conda install -y samtools

# # bwa 0.7.17
conda install -y minimap2

conda deactivate