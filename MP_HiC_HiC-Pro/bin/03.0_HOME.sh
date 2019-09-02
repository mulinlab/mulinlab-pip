#!/bin/bash

cells=("jurkat")
cpu=20

hg="hg19"
enzyme="HindIII"
cutsite="AAGCTT"
bin=5000
sbin="5kb"

gfa="../00_hg19/${hg}.fa"

dsam="../test_result/02.1_sam_${hg}_${enzyme}_${sbin}"
dhm="../test_result/02_homer_${hg}_${enzyme}_${sbin}"

for cell in "${cells[@]}"
do
  sam1="$dsam/${cell}_1.sam"
  sam2="$dsam/${cell}_2.sam"

  dot="$dhm/${cell}_tags"
  mkdir -p $dot

  dol="$dhm/${cell}_logs"
  mkdir -p $dol

  fosi="$dhm/${cell}_sigInteractions.txt"

  echo "STEP[1/3]: Pairing reads for $cell"
  makeTagDirectory $dot $sam1,$sam2 -tbp 1 2> $dol/${cell}_pairing.log

  echo "STEP[2/3]: Filtering reads for $cell"
  makeTagDirectory $dot -update -checkGC -genome $gfa -removePEbg -restrictionSite $cutsite -both -removeSelfLigation -removeRestrictionEnds -removeSpikes 10000 5 2> $dol/${cell}_filtering.log

  echo "STEP[3/3]: Interactions calling for $cell"
  analyzeHiC $dot -res $bin -nomatrix -interactions $fosi -cpu $cpu 2> $dol/${cell}_interactions.log
done
