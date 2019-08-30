#!/bin/bash

########################################################

# GATK Best Practice
# Data Pre-processing
# Author: Jianhua Wang (jianhua.mert@gmail.com)
# Date: 19-08-2019

########################################################

## parameters
INPUT=../input
OUTPUT=../output
fq1=$1
fq2=$2
sample=$3

REF=../reference

## runtime
minimap2_threads=8
sort_threads=4
sort_memory=4G

## tools
GATK=./gatk-4.1.3.0/gatk

#########################################################
mkdir $sample

# align
minimap2 \
-t minimap2_threads \
-R '@RG\tID:'${sample}'\tSM:'${sample}'\tLB:'${sample}'\tPL:Illumina' \
-ax sr \
../reference/human_g1k_v37.fasta.mmi $fq1 $fq2 | \
samtools view -S -b - > ./$sample/${sample}.bam

# sort
samtools sort -@ $sort_threads -m $sort_memory -O bam -o ./$sample/${sample}.sorted.bam ./$sample/${sample}.bam

# mark duplicates
$GATK \
MarkDuplicates \
-I ./${sample}/${sample}.sorted.bam \
-O ./${sample}/${sample}.markdup.bam \
-M ./${sample}/${sample}.markdup_metrics.txt

samtools index ./${sample}/${sample}.markdup.bam

# BQSR
$GATK \
BaseRecalibrator \
-R $REF/human_g1k_v37.fasta \
-I ./${sample}/${sample}.markdup.bam \
--known-sites $REF/dbsnp_138.b37.vcf \
--known-sites $REF/Mills_and_1000G_gold_standard.indels.b37.vcf \
-O ./${sample}/${sample}.recal_data.table

$GATK \
ApplyBQSR \
-R $REF/human_g1k_v37.fasta \
-I ./${sample}/${sample}.markdup.bam \
-bqsr ./${sample}/${sample}.recal_data.table \
-O ${OUTPUT}/${sample}.markdup.bqsr.bam

rm -rf $sample