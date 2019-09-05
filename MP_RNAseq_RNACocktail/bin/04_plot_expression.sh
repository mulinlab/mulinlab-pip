#!/bin/bash

# Functions are not exported by default to be made available in subshells, so:
eval "$(conda shell.bash hook)"

conda activate RNACocktail
Rscript bin/04.1_dist_pca.R $1
conda deactivate
