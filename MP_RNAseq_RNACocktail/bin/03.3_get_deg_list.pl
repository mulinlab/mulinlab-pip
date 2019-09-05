#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;

my $adjp = 0.05;

my $wd = $ARGV[0];
my $di   = "$wd/deg";
my @dirs = glob "$di/*";

foreach my $dio (@dirs) {
    my @files;
    if ( $dio =~ /salmon|stringtie/ ) {
        @files = glob "$dio/*_tpm.txt";
    }
    else {
        @files = glob "$dio/*_count.txt";
    }

    foreach my $fi (@files) {
        my $fo = $fi;
        $fo =~ s/count/genes/g;
        $fo =~ s/tpm/genes/g;
        my %hash;
        open my $I, '<', $fi
          or die "$0 : failed to open input file '$fi' : $!\n";
        while (<$I>) {
            unless (/^GeneID/) {
                chomp;
                my @f = split /\t/;
                if ( $f[5] =~ /\d/ && $f[5] <= $adjp && abs($f[2])>=1 ) {
                    $f[0] =~ s/\.\d+$//;
                    my $gene = join "\t", @f[ 0, 1 ];
                    $hash{$gene} = 1;
                }
            }
        }
        close $I or warn "$0 : failed to close input file '$fi' : $!\n";

        open my $O, '>', $fo
          or die "$0 : failed to open output file '$fo' : $!\n";
        select $O;
        print "geneID\tsymbol\n";
        foreach my $gene ( sort keys %hash ) {
            print "$gene\n";
        }
        close $O or warn "$0 : failed to close output file '$fo' : $!\n";

    }
}

