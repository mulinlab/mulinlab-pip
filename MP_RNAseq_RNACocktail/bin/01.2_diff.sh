#!/bin/bash

dig=$1 # reference folder
diw=$2 # work folder
gtf="$dig/gencode.gtf"

doo="$diw/RNACocktail_out"
dow="$diw/RNACocktail_work"

conf_sample="samples.conf"
conf_diff="diff.conf"


function join_by { local IFS="$1"; shift; echo "$*"; }


function run_diff_hisat2 {
	arr_xIDs=($1)
	arr_yIDs=($2)
	id=$3

	str_xNAMEs=$(join_by , "${arr_xIDs[@]}")
	str_yNAMEs=$(join_by , "${arr_yIDs[@]}")

	declare -a arr_xBAMs
	declare -a arr_yBAMs
	for i in "${!arr_xIDs[@]}"
	do
		arr_xBAMs[$i]="/work_dir/$doo/hisat2/${arr_xIDs[$i]}/alignments.sorted.bam"
	done
	for i in "${!arr_yIDs[@]}"
	do
		arr_yBAMs[$i]="/work_dir/$doo/hisat2/${arr_yIDs[$i]}/alignments.sorted.bam"
	done
	str_xBAMs=$(join_by , "${arr_xBAMs[@]}")
	str_yBAMs=$(join_by , "${arr_yBAMs[@]}")

	docker run -v ${PWD}:/work_dir/:z marghoob/rnacocktail run_rnacocktail.py diff \
		--alignments $str_xBAMs $str_yBAMs \
		--sample $str_xNAMEs $str_yNAMEs \
		--ref_gtf /work_dir/$gtf \
		--outdir /work_dir/$doo/diff_hisat2/$id \
		--workdir /work_dir/$dow/diff_hisat2/$id
}


function run_diff_hisat2_stringtie {
	arr_xIDs=($1)
	arr_yIDs=($2)
	id=$3

	str_xNAMEs=$(join_by , "${arr_xIDs[@]}")
	str_yNAMEs=$(join_by , "${arr_yIDs[@]}")

	declare -a arr_xBAMs
	declare -a arr_yBAMs
	for i in "${!arr_xIDs[@]}"
	do
		arr_xBAMs[$i]="/work_dir/$doo/hisat2/${arr_xIDs[$i]}/alignments.sorted.bam"
	done
	for i in "${!arr_yIDs[@]}"
	do
		arr_yBAMs[$i]="/work_dir/$doo/hisat2/${arr_yIDs[$i]}/alignments.sorted.bam"
	done
	str_xBAMs=$(join_by , "${arr_xBAMs[@]}")
	str_yBAMs=$(join_by , "${arr_yBAMs[@]}")

	declare -a arr_xGTFs
	declare -a arr_yGTFs
	for i in "${!arr_xIDs[@]}"
	do
		arr_xGTFs[$i]="/work_dir/$doo/stringtie/${arr_xIDs[$i]}/transcripts.gtf"
	done
	for i in "${!arr_yIDs[@]}"
	do
		arr_yGTFs[$i]="/work_dir/$doo/stringtie/${arr_yIDs[$i]}/transcripts.gtf"
	done
	str_xGTFs=$(join_by , "${arr_xGTFs[@]}")
	str_yGTFs=$(join_by , "${arr_yGTFs[@]}")

	docker run -v ${PWD}:/work_dir/:z marghoob/rnacocktail run_rnacocktail.py diff \
		--alignments $str_xBAMs $str_yBAMs \
		--transcripts_gtfs $str_xGTFs $str_yGTFs \
		--sample $str_xNAMEs $str_yNAMEs \
		--ref_gtf /work_dir/$gtf \
		--outdir /work_dir/$doo/diff_hisat2_stringtie/$id \
		--workdir /work_dir/$dow/diff_hisat2_stringtie/$id
}


function run_diff_salmon {
	arr_xIDs=($1)
	arr_yIDs=($2)
	id=$3

	str_xNAMEs=$(join_by , "${arr_xIDs[@]}")
	str_yNAMEs=$(join_by , "${arr_yIDs[@]}")

	declare -a arr_xSFs
	declare -a arr_ySFs
	for i in "${!arr_xIDs[@]}"
	do
		arr_xSFs[$i]="/work_dir/$doo/salmon_smem/${arr_xIDs[$i]}/quant.sf"
	done
	for i in "${!arr_yIDs[@]}"
	do
		arr_ySFs[$i]="/work_dir/$doo/salmon_smem/${arr_yIDs[$i]}/quant.sf"
	done
	str_xSFs=$(join_by , "${arr_xSFs[@]}")
	str_ySFs=$(join_by , "${arr_ySFs[@]}")

	docker run -v ${PWD}:/work_dir/:z marghoob/rnacocktail run_rnacocktail.py diff \
		--quant_files $str_xSFs $str_ySFs \
		--sample $str_xNAMEs $str_yNAMEs \
		--ref_gtf /work_dir/$gtf \
		--outdir /work_dir/$doo/diff_salmon/$id \
		--workdir /work_dir/$dow/diff_salmon/$id
}



declare -A hash

IFS=$'\n'       # make newlines the only separator
for line in $(grep -v "sample_IDs" $conf_sample)
do
  array=($(echo $line | tr '\t' '\n'))
  hash[${array[0]}]=${array[1]}
done

for line in $(grep -v "group_control" $conf_diff)
do
  g1=$(echo $line | cut -f1)
  g2=$(echo $line | cut -f2)
  
  g1s=($(echo ${hash[$g1]} | tr ',' '\n'))
  g2s=($(echo ${hash[$g2]} | tr ',' '\n'))

  did="${g1}_${g2}"

  run_diff_hisat2 "${g1s[*]}" "${g2s[*]}" "$did"
  run_diff_hisat2_stringtie "${g1s[*]}" "${g2s[*]}" "$did"
  run_diff_salmon "${g1s[*]}" "${g2s[*]}" "$did"
done

