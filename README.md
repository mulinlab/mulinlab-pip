# mulinlab-pip
mulinlab bioinformatics pipelines for reproducible, efficient and convenient bioinformatics research.

Each pipeline is saved in a folder which is named by the pipeline name.

---

## Pre-processing

* [MP_preSeq_FastQC](./MP_preSeq_FastQC/README.md): Quality control for NGS reads using FastQC

---

## DNA-seq

* [MP_DNAseq_germline_GATK](./MP_DNAseq_germline_GATK/README.md): Calling germline SNVs and InDels for single sample or cohort using GATK
* [MP_DNAseq_common_CNV](./MP_DNAseq_common_CNV/README.md) : Call copy number variants (CNVs) from targeted sequence data, typically exome sequencing experiments using R package **ExomeDepth**

---

## RNA-seq

* [MP_RNAseq_RNACocktail](./MP_RNAseq_RNACocktail/README.md): RNA-seq analysis using RNACocktail, from sequencing reads to differential expression genes, including several plots

---

## ChIP-seq

* [MP_ChIPseq_BDS](./MP_ChIPseq_BDS/README.md): Transcription Factor and Histone ChIP-seq processing pipeline using BDS (BigDataScript)

---

## ATAC-seq

* [MP_ATACseq_BDS](.MP_ATACseq_BDS/README.md): ATAC-seq or DNase-seq data processing pipeline

----

## 4C-seq

---

* [MP_4Cseq_4Cseqpipe](./MP_4Cseq_4Cseqpipe/README.md): Mapping and analyzing 4C-seq experiments using 4Cseqpipe

---

## Hi-C

* [MP_HiC_HiC-Pro](./MP_HiC_HiC-Pro/README.md): Hi-C data processing pipeline using HiC-Pro

---

## QTLs

* [MP_eQTL_QTLtools](./MP_eQTL_QTLtools/README.md): eQTL-mapping using QTLtools

---

## GWAS

* [MP_GWAS](./MP_GWAS/README.md): A suit of GWAS workflows for [CHIMGEN]([http://chimgen.tmu.edu.cn](http://chimgen.tmu.edu.cn/)) project built on [NEXTFLOW](<https://www.nextflow.io/>) framework
* [MP_GWAS_fine_mapping](./MP_GWAS_fine_mapping/README.md): Summary statistics based fine-mapping using three commonly-used tools