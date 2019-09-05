#!/bin/bash

# $1: reference folder
# $2: reads folder
# $3: output/work folder
bash bin/01.1_align.sh $1 $2 $3
bash bin/01.2_diff.sh $1 $3
