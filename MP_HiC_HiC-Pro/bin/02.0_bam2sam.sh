#!/bin/bash

cells=("jurkat")
cpu=25

hg="hg19"
enzyme="HindIII"
bin="5000"
sbin="5kb"

dhp="../test_result/01_hicpro_${hg}_${enzyme}_${sbin}/bowtie_results/bwt2"
dsam="../test_result/02.1_sam_${hg}_${enzyme}_${sbin}"
mkdir $dsam

for cell in "${cells[@]}"
do
  di="$dhp/${cell}"
  bam1="$di/${cell}_1_${hg}.bwt2merged.bam"
  bam2="$di/${cell}_2_${hg}.bwt2merged.bam"

  sam1="$dsam/${cell}_1.sam"
  sam2="$dsam/${cell}_2.sam"

  samtools view -h -@ $cpu $bam1 > $sam1
  samtools view -h -@ $cpu $bam2 > $sam2
done
