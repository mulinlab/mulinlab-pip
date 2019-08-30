#!/bin/bash

# bcftools view --min-af 0.01:minor inputs/genotypes.chr22.vcf.gz -Oz -o geno.maf0.01.vcf.gz --threads 12
# tabix -p vcf geno.maf0.01.vcf.gz

export PATH="$PWD/qtltools:$PATH"

genotype=$1 
phenotype=$2
prefix=$3
num_peer=$4
add_covariates=$5
QTLtools pca --vcf ${genotype} --scale --center --distance 50000 --out ${prefix}
head -n 4 ${prefix}.pca | sed 's/ /\t/g' > ${prefix}.top3.pca
Rscript src/run_PEER.R ${phenotype} ${prefix} ${num_peer}
python src/combine_covariates.py ${prefix}.PEER_covariates.txt ${prefix} \
    --genotype_pcs ${prefix}.top3.pca \
    --add_covariates ${add_covariates}

sed -i 's/\t/ /g' ${prefix}.combined_covariates.txt 
gzip ${prefix}.combined_covariates.txt