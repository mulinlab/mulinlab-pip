#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $wd  = $ARGV[0];                  # work folder
my $dio = "$wd/expression/salmon";

my @sids;
my %tpm;
my $fi = "$dio/salmon_tpm_tx.txt";
open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
while (<$I>) {
    chomp;
    my @f = split /\t/;
    if (/^txID/) {
        @sids = @f[ 3 .. $#f ];
    }
    else {
        my $g = join "\t", @f[ 1, 2 ];
        for ( my $i = 0 ; $i < @sids ; $i++ ) {
            my $j = $i + 3;
            push @{ $tpm{$g}->{ $sids[$i] } }, $f[$j];
        }
    }
}
close $I or warn "$0 : failed to close input file '$fi' : $!\n";

my $fo = "$dio/salmon_tpm_gene.txt";
open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
print "geneID\tsymbol\t";
print join "\t", @sids;
print "\n";
foreach my $g ( sort keys %tpm ) {
    print "$g";
    foreach my $sid (@sids) {
        my $te;
        my @exp = @{ $tpm{$g}->{$sid} };
        $te += $_ foreach @exp;
        print "\t$te";
    }
    print "\n";
}
close $O or warn "$0 : failed to close output file '$fo' : $!\n";
