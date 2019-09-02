#!/bin/bash

hg="hg19"
enzyme="HindIII"
bin=5000
sbin="5kb"

dfq="../test_result/01.00_fq_${enzyme}"
dhp="../test_result/01_hicpro_${hg}_${enzyme}_${sbin}"
fcfg="../00_cfg4hicpro/${hg}_${enzyme}_${sbin}.cfg"

source activate py2
/home/zhengzhanye/pipeline/hic_pro/HiC-Pro_2.11.1/bin/HiC-Pro -i $dfq -o $dhp -c $fcfg
source deactivate   py2