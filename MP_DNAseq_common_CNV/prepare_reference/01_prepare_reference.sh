#!/bin/bash

#download

cd ../ref
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37.fasta.fai.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37.fasta.gz

## decompress

gzip -d human_g1k_v37.fasta.fai.gz
gzip -d human_g1k_v37.fasta.gz
