#!/bin/bash

########################################################

# GATK Best Practice
# Germline SNPs + Indels (single sample)
# Author: Jianhua Wang (jianhua.mert@gmail.com)
# Date: 19-08-2019

########################################################

## parameters
INPUT=../input
OUTPUT=../output
bam=$1
sample=$2
REF=../reference

## tools
GATK=./gatk-4.1.3.0/gatk
bwa=./bwa-0.7.17/bwa
samtools=./samtools-1.9/samtools

#########################################################

mkdir $sample

# HaplotypeCaller
$GATK \
HaplotypeCaller \
-I $bam \
-R $REF/human_g1k_v37.fasta \
-D $REF/dbsnp_138.b37.vcf \
-O ${sample}/${sample}.HC.vcf

conda activate gatk

# CNNscore
$GATK \
CNNScoreVariants \
-I $bam \
-V ${sample}/${sample}.HC.vcf \
-R $REF/human_g1k_v37.fasta \
-O ${sample}/${sample}.HC.CNNscore.vcf \
-tensor-type read_tensor

# Apply filter
$GATK \
FilterVariantTranches \
-V ${sample}/${sample}.HC.CNNscore.vcf \
-O ${OUTPUT}/${sample}.HC.CNNscore.filtered.vcf \
-resource $REF/hapmap_3.3.b37.vcf \
-resource $REF/1000G_omni2.5.b37.vcf \
-resource $REF/1000G_phase1.snps.high_confidence.b37.vcf \
-resource $REF/dbsnp_138.b37.vcf \
-resource $REF/Mills_and_1000G_gold_standard.indels.b37.vcf

conda deactivate
rm -rf $sample