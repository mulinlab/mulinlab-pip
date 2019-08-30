#!/bin/bash

echo "======================="

# directory containing FASTQs
[ -z $1 ] && (echo "The directory containing FASTQs or FASTQ files must be specified!" && exit 1)
([ -d $1 ] || [ -f $1 ]) || (echo "The directory or files must esixt!" && exit 1)
dir_file_in=$1

# directory to save results
[ -z $2 ] && echo "The directory saving outputs is set to current folder (.)!"
dir_out=${2:-"."}
[ -d $dir_out ] || (mkdir -p $dir_out && echo "The output directory '$dir_out' is created!")

# threads to use
[ -z $3 ] && echo "10 threads will be used to run this pipeline!"
num_cpus=${3:-10}

echo
if [ -d $dir_file_in ]
then
  cmd="fastqc -o $dir_out -t $num_cpus $dir_file_in/*"
else
  cmd="fastqc -o $dir_out -t $num_cpus $dir_file_in"
fi

echo -e "Run:\t$cmd"
echo "======================="
echo

$cmd
