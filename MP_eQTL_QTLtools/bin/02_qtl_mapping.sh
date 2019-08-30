#!/bin/bash
export PATH="$PWD/qtltools:$PATH"

mkdir tmp
genotype=$1 
phenotype=$2
covariates=$3
condi_output_dir="condi_output"
mkdir ${condi_output_dir}

for j in $(seq 1 16); do
  echo "cis --vcf ${genotype} --bed ${phenotype} --cov ${covariates} --permute 200 --chunk $j 16 --out tmp/permutations_${j}_16.txt";
done | xargs -P12 -n14 QTLtools
cd tmp
cat permutations_*.txt | gzip -c > permutations_all.txt.gz
Rscript ../qtltools/script/runFDR_cis.R permutations_all.txt.gz 0.05 permutations_all
cd ..
for j in $(seq 1 16); do
    echo "cis --vcf ${genotype} --bed ${phenotype} --cov ${covariates} --mapping tmp/permutations_all.thresholds.txt --chunk $j 16 --out ${condi_output_dir}/conditional_${j}_16.txt" ;
done | xargs -P12 -n14 QTLtools

cat ${condi_output_dir}/conditional_*.txt | awk '{ if ($19 == 1) print $0}' > conditional_top_variants.txt
rm -rf tmp
rm -rf ${condi_output_dir}