

# eQTL-mapping

## Description

eQTL-mapping using QTLtools

## inputs

### Genotype data

Format : bgzip compressed VCF & corresponding tabix index file

*Note* : **Quality control** is needed in this step.

remove samples without gene expression data.

remove rare variants (MAF < 0.01) using bcftools as follows:

```shell
bcftools view --min-af 0.01:minor geno.vcf.gz -Oz -o geno.maf0.01.vcf.gz --threads 12
```

### Phenotype data

Format : bgzip compressed BED & corresponding tabix index file

Hereafter a general example of 4 molecular phenotypes for 4 samples.

```
#Chr	start	end	pid	gid	strand	UNR1	UNR2	UNR3	UNR4 
chr1	99999	100000	pheno1	pheno1	+	-0.50	0.82	-0.71	0.83
chr1	199999	201000	pheno2	pheno2	+	1.18	-2.84	1.34	-1.56
chr1	299999	300000	exon1	gene1	+	-1.13	1.18	-0.03	0.11
chr1	299999	300000	exon2	gene1	+	-1.18	1.32	-0.36	1.26
```

This file is *TAB* delimited. Each line corresponds to a single molecular phenotype. The first 6 columns are:

1. Chromosome ID *[string]*
2. Start genomic position of the phenotype (here the TSS of gene1) *[integer, 0-based]*
3. End genomic position of the phenotype (here the TSS of gene1) *[integer, 1-based]*
4. Phenotype ID (here the exon IDs) *[string]*.
5. Phenotype group ID (here the gene IDs, multiple exons belong to the same gene) *[string]*
6. Strand orientation *[+/-]*

Then each additional column gives the quantification for a sample. Quantifications are encoded with floating numbers. This file should have P lines and N+6 columns where P and N are the numbers of phenotypes and samples, respectively.

### Covariate data

Format : bgzip compressed TXT file

Hereafter an example of 4 covariates for 4 samples.

```
id UNR1 UNR2 UNR3 UNR4
PC1 -0.02 0.14 0.16 -0.02
PC2 0.01 0.11 0.10 0.01
PC3 0.03 0.05 0.08 0.07
BIN 1 0 0 1
```

Hereafter, some properties of this file:

1. The file is white space delimited

2. First row gives the sample ID and each additional one corresponds to a single covariate

3. First column gives the covariate ID and each additional one corresponds to a sample

4. The file should have S+1 rows and C+1 columns where S and C are the numbers of samples and covariates, respectively

**Covariates commonly used in eQTL analysis**:

- Top 3 genotyping principal components.

  ```shell
  QTLtools pca --vcf inputs/genotypes.chr22.vcf.gz --scale --center --distance 50000 --out genotypes.chr22
  head -n 4 genotypes.chr22.pca > top_three_PCs.txt
  ```

  options:

  - *--center* and *--scale* can be used to enforce centering and scaling of the phenotype values prior to the PCA.
  - *--maf 0.05* to only consider variant sites with a Minor Allele Frequency (MAF) above 5%
  - *--distance 50000* to only consider variant sites separated by at least 50kb

- PEER factors that calculated for the normalized expression matrices. The number of PEER factors was determined as function of sample size (N): 15 factors for N<150, 30 factors for 150≤ N<250, 45 factors for 250≤ N<350, and 60 factors for N≥350

  ```shell
  Rscript run_PEER.R ${prefix}.expression.bed.gz ${prefix} ${num_peer} 
  ```

 This R script is provided in /src folder, and the peer source package can be downloaded from https://github.com/PMBio/peer/wiki/Installation-instructions, then install with commandline as follows:

```shell
R CMD INSTALL R_peer_source_1.3.tgz
```

- Genotyping platform (Illumina HiSeq 2000 or HiSeq X).

- Sex.

  Coded as 1/2

Combine covarites files:

```
python combine_covariates.py ${prefix}.PEER_covariates.txt ${prefix} 
    --genotype_pcs ${genotype_pcs} 
    --add_covariates ${add_covariates}
```

This *combine_covariates.py* python script is provided in /src folder.

In this pipeline, you can input genotype,phenotype,output_prefix,N_peers and gender files to produce covariates file (see usage).





## Main Steps Interpretation

### Step1: Run the permutation pass

```shell
for j in $(seq 1 16); do
  echo "cis --vcf ${genotype} --bed ${phenotype} --cov ${covariates} --permute 200 --chunk $j 16 --out tmp/permutations_${j}_16.txt";
done | xargs -P12 -n14 QTLtools
```

Then, cat all chunks together and run FDR correction:

```shell
cat permutations_*.txt | gzip -c > permutations_all.txt.gz
Rscript ../qtltools/script/runFDR_cis.R permutations_all.txt.gz 0.05 permutations_all
```

From this, you get a file *permutations_all.thresholds.txt* with the nominal P-value thresholds that you need for the conditional analysis

### Step2: Run the conditional analysis

```shell
for j in $(seq 1 16); do
    echo "cis --vcf ${genotype} --bed ${phenotype} --cov ${covariates} --mapping tmp/permutations_all.thresholds.txt --chunk $j 16 --out ${condi_output_dir}/conditional_${j}_16.txt" ;
done | xargs -P12 -n14 QTLtools
```

Now, run all chunks and if you are only interested in the top variant for each signal, you can filter out the results for the column 19 as follows:

```shell
cat ${condi_output_dir}/conditional_*.txt | awk '{ if ($19 == 1) print $0}' > conditional_top_variants.txt
```

column 12 is  **Rank of the association**, this tells you if the variant has been mapped as belonging to the best signal (rank=0), the second best (rank=1), etc ... As a consequence, the maximal rank value for a given phenotype tells you how many independent signals there are (e.g. rank=2 means 3 independent signals).

see detailed output file columns description: https://qtltools.github.io/qtltools/pages/mode_cis_conditional.html

**These procedures have been integrated in to shell scripts in /bin folder**

## Usage

```shell
# set up
cd bin
sh 00_set_up.sh

# prepare covariates
sh bin/01_prepare_covariates.sh ${genotype} ${phenotype} ${prefix} ${N_peers} ${gender}
#eg:
#sh bin/01_prepare_covariates.sh inputs/genotypes.chr22.vcf.gz inputs/genes.50percent.chr22.expression.bed.gz chr22 45 inputs/sex.txt

# eQTL mapping
bin/02_qtl_mapping.sh ${genotype} ${phenotype} ${covariates}
#eg:
#sh bin/02_qtl_mapping.sh inputs/genotypes.chr22.vcf.gz inputs/genes.50percent.chr22.expression.bed.gz chr22.combined_covariates.txt.gz
```



## Outputs

White-space delimited file ***conditional_top_variants.txt*** for significant eQTLs with independent effects.

With the various columns giving:

- 1. Phenotype ID
- 2. Phenotype chr ID
- 3. Phenotype start position
- 4. Phenotype end position
- 5. Phenotype strand orientation
- 6. Number of variants tested in *cis*
- 7. Distance between the variant and the phenotype
- 8. Variant ID
- 9. Variant chr ID
- 10. Variant start position
- 11. Variant end position
- 12. **Rank of the association**. This tells you if the variant has been mapped as belonging to the best signal (rank=0), the second best (rank=1), etc ... As a consequence, the maximal rank value for a given phenotype tells you how many independent signals there are (e.g. rank=2 means 3 independent signals).
- 13. Forward nominal P-value
- 14. Forward regression slope
- 15. Binary flag; 1 means that the variant is the top forward variant of this rank, 0 otherwise
- 16. Binary flag; 1 means that the forward P-value is below the threshold of this phenotype, 0 otherwise
- 17. Backward nominal P-value
- 18. Backward regression slope
- 19. Binary flag; 1 means that the variant is the top backward variant of this rank, 0 otherwise
- 20. Binary flag; 1 means that the backward P-value is below the threshold of this phenotype, 0 otherwise

For example:

```
ENSG00000188130.9 chr22 50700254 50700254 - 5139 -93 rs11913279 chr22 50700347 50700347 0 2.25986e-09 -0.278047 1 1 1.58737e-12 -0.724656 1 1
ENSG00000188130.9 chr22 50700254 50700254 - 5139 94985 rs116914202 chr22 50605269 50605269 1 7.6825e-05 -0.533554 0 1 7.58821e-06 -0.602191 1 1
ENSG00000188130.9 chr22 50700254 50700254 - 5139 65061 rs4084288 chr22 50635193 50635193 2 7.29639e-05 -0.347478 1 1 7.29639e-05 -0.347478 1 1
```

From this, you can see that the gene *ENSG00000188130.9* has three significant eQTLs with independent effects: *rs11913279* (rank=0), *rs116914202* (rank=1) and *rs4084288* (rank=2).

## References:

https://www.gtexportal.org/home/documentationPage

https://qtltools.github.io/qtltools/

https://qtltools.github.io/qtltools/pages/mode_cis_conditional.html
