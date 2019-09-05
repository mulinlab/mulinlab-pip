#!/bin/bash

dig=$1 # reference folder
dir=$2 # reads folder
dout=$3 # output folder

conf_sample="samples.conf"
conf_other="others.conf"

doo="$dout/RNACocktail_out"
mkdir -p $doo
dow="$dout/RNACocktail_work"
mkdir -p $dow

gtf="$dig/gencode.gtf"
cpus=$(grep -w "cpus" ${conf_other} | cut -f2)

samples=($(grep -v "sample_IDs" ${conf_sample} | cut -f2 | tr "," "\n"))

# align
for sid in ${samples[@]}
do
  id=${sid}
  fq1="$dir/${sid}_1.fastq.gz"
  fq2="$dir/${sid}_2.fastq.gz"
  docker run -v ${PWD}:/work_dir/:z marghoob/rnacocktail run_rnacocktail.py align \
    --align_idx /work_dir/$dig/HISAT2Index/genome \
    --outdir /work_dir/$doo \
    --workdir /work_dir/$dow \
    --ref_gtf /work_dir/$gtf \
    --1 /work_dir/$fq1 \
    --2 /work_dir/$fq2 \
    --sample $id \
    --threads $cpus
done

# reconstruct
for sid in ${samples[@]}
do
  id=${sid}
  docker run -v ${PWD}:/work_dir/:z marghoob/rnacocktail run_rnacocktail.py reconstruct \
    --alignment_bam /work_dir/$doo/hisat2/$id/alignments.sorted.bam \
    --outdir /work_dir/$doo \
    --workdir /work_dir/$dow \
    --ref_gtf /work_dir/$gtf \
    --sample $id \
    --threads $cpus
done

# quantify
for sid in ${samples[@]}
do
  id=${sid}
  fq1="$dir/${sid}_1.fastq.gz"
  fq2="$dir/${sid}_2.fastq.gz"
  docker run -v ${PWD}:/work_dir/:z marghoob/rnacocktail run_rnacocktail.py quantify \
    --quantifier_idx /work_dir/$dig/SalmonIndex \
    --1 /work_dir/$fq1 \
    --2 /work_dir/$fq2 \
    --libtype IU \
    --salmon_k 19 \
    --outdir /work_dir/$doo \
    --workdir /work_dir/$dow \
    --threads $cpus \
    --sample $id \
    --unzip
done

