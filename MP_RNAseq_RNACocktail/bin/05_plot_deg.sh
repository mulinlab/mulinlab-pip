#!/bin/bash

# Functions are not exported by default to be made available in subshells, so:
eval "$(conda shell.bash hook)"

conda activate RNACocktail
Rscript bin/05.1_volcano.R $1
Rscript bin/05.2_heatmap.R $1
conda deactivate
