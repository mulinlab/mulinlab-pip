#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my @cells = ("jurkat");  
## my @cells = ("jurkat","k562");   # if you have many cell type to processed ,you only need write like this;
my $enzyme = "HindIII";             ## enzyme that used in hic exprement

#my $di = "00_fastq";
my $di = "../test_data";
my $dt = "../test_result";
mkdir $dt unless -d $dt;
my $do = "$dt/01.00_fq_${enzyme}";
mkdir $do unless -d $do;

foreach my $cell (@cells) {
    my $id  = "$cell";
    my $df  = "$di";
    my $ff1 = "$df/Hic_hind_1.clean.fq.gz";
    my $ff2 = "$df/Hic_hind_2.clean.fq.gz";
    my $dt  = "$do/$cell";
    mkdir $dt unless -d $dt;
    my $ft1 = "$dt/${cell}_1.fastq.gz";
    my $ft2 = "$dt/${cell}_2.fastq.gz";
    link( $ff1, $ft1 );
    link( $ff2, $ft2 );
}

