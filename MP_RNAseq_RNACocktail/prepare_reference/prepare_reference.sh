#!/bin/bash

wd=$1
sid=$2
script_bin="bin"
conf_species="species.conf"
conf_other="others.conf"

gb=$(grep -w $sid $conf_species | cut -f2)
rv=$(grep -w $sid $conf_species | cut -f3)
cpus=$(grep -w "cpus" $conf_other | cut -f2)

dout="${wd}/${gb}_v${rv}"

# Step0: prepare output directory
mkdir -p $dout
cd $dout

# Step1: download genome sequence and gene annotation
base_url="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_${sid}/release_${rv}"
if [ $gb = "GRCh37" ]
then
  base_usrl="${base_url}/${gb}_mapping"
fi
wget -c ${base_url}/${gb}.primary_assembly.genome.fa.gz
gz_dna="${gb}.primary_assembly.genome.fa.gz"
if [ $gb = "GRCh37" ]
then
  wget -c ${base_url}/gencode.v${rv}lift37.annotation.gtf.gz
  gz_gtf="genocode.v${rv}lift37.annotation.gtf.gz"
else
  wget -c ${base_url}/gencode.v${rv}.annotation.gtf.gz
  gz_gtf="gencode.v${rv}.annotation.gtf.gz"
fi
# zcat .gz to specific name
bn_dna="genome"
dna="${bn_dna}.fa"
gtf="gencode.gtf"
zcat ${gz_dna} > $dna
zcat ${gz_gtf} > $gtf

# Step2: dict genome
# Functions are not exported by default to be made available in subshells, so:
eval "$(conda shell.bash hook)"
conda activate RNACocktail
samtools faidx $dna
samtools dict $dna -o ${bn_dna}.dict
conda deactivate

# Step3: index genome with HISAT2
doih="HISAT2Index"
mkdir -p $doih
docker run -v ${PWD}/:/work_dir/:z marghoob/rnacocktail hisat2-build \
	/work_dir/${dna} \
	/work_dir/${doih}/${bn_dna} \
	-p ${cpus}

# Step4: get cDNA sequence
cdna="cdna.fa"
docker run -v ${PWD}/:/work_dir/:z marghoob/rnacocktail gffread \
	/work_dir/${gtf} \
	-g /work_dir/${dna} \
	-w /work_dir/${cdna}

# Step5: index cDNA with Salmon-SMEM
dois="SalmonIndex"
mkdir -p $dois
docker run -v ${PWD}/:/work_dir/:z marghoob/rnacocktail salmon index \
	-t /work_dir/${cdna} \
	-i /work_dir/${dois} \
	--type fmd \
	-p ${cpus}


# change directory to the main folder
cd -

# Step6: extract symbol and biotype from gencode.gtf
perl ${script_bin}/gencode_ensg2symbol.pl $dout
perl ${script_bin}/gencode_gene2type.pl $dout

# Step7: chown
# sudo chown -R $USER:$USER $dout

