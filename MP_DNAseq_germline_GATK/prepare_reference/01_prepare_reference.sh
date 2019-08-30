#!/bin/bash

# download
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37.dict.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37.fasta.fai.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37.fasta.gz

wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_omni2.5.b37.vcf.idx.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_omni2.5.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.snps.high_confidence.b37.vcf.idx.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.snps.high_confidence.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/hapmap_3.3.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/hapmap_3.3.b37.vcf.idx.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/dbsnp_138.b37.vcf.idx.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.idx.gz

# decompress
gzip -d human_g1k_v37.dict.gz
gzip -d human_g1k_v37.fasta.fai.gz
gzip -d human_g1k_v37.fasta.gz

gzip -d 1000G_omni2.5.b37.vcf.idx.gz
gzip -d 1000G_omni2.5.b37.vcf.gz
gzip -d 1000G_phase1.snps.high_confidence.b37.vcf.idx.gz
gzip -d 1000G_phase1.snps.high_confidence.b37.vcf.gz
gzip -d hapmap_3.3.b37.vcf.gz
gzip -d hapmap_3.3.b37.vcf.idx.gz
gzip -d dbsnp_138.b37.vcf.gz
gzip -d dbsnp_138.b37.vcf.idx.gz
gzip -d Mills_and_1000G_gold_standard.indels.b37.vcf.gz
gzip -d Mills_and_1000G_gold_standard.indels.b37.vcf.idx.gz

# create minimap2 index
minimap2 -d human_g1k_v37.fasta.mmi human_g1k_v37.fasta