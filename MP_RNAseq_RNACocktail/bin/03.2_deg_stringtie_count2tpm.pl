#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $wd= $ARGV[0];
my $di = "$wd/expression/stringtie";
my $do = "$wd/deg/diff_hisat2_stringtie";

my @sids;
my %tpm;
my $fit = "$di/stringtie_tpm_gene.txt";
open my $IT, '<', $fit or die "$0 : failed to open input file '$fit' : $!\n";
while (<$IT>) {
    chomp;
    my @f = split /\t/;
    if (/^ENS/) {
        my $g = $f[0];
        for ( my $i = 0 ; $i < @sids ; $i++ ) {
            my $j = $i + 2;
            $tpm{$g}->{ $sids[$i] } = $f[$j];
        }
    }
    else {
        @sids = @f[ 2 .. $#f ];
    }
}
close $IT or warn "$0 : failed to close input file '$fit' : $!\n";

my @fis = glob "$do/*_count.txt";
foreach my $fi (@fis) {
    my @sids;
    my $fo = $fi;
    $fo =~ s/count/tpm/;
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    while (<$I>) {
        chomp;
        my @f = split /\t/;
        if (/^GeneID/) {
            @sids = @f[ 6 .. $#f ];
            print join "\t", @f;
            print "\n";
        }
        elsif (/^ENS/) {
            my $g = $f[0];
            print join "\t", @f[ 0 .. 5 ];
            foreach my $sid (@sids) {
                print "\t$tpm{$g}->{$sid}";
            }
            print "\n";
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

