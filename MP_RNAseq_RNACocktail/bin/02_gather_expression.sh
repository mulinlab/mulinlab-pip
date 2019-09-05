#!/bin/bash

# $1: reference folder
# $2: work folder
perl bin/02.1_get_exp_stringtie.pl $1 $2
perl bin/02.2_get_exp_salmon.pl $1 $2
perl bin/02.3_salmon_tx2gene.pl $2
