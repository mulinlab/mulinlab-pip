#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;

my $dir = $ARGV[0];
my $di = $ARGV[1];

my $dod = $ARGV[2];
mkdir $dod unless -d $dod;
my $bn = basename($di);
my $do = "$dod/$bn";
mkdir $do unless -d $do;

my $fig = "$dir/gencode_id2symbol.txt";
my %id2symbol;
open my $IG, '<', $fig or die "$0 : failed to open input file '$fig' : $!\n";
while (<$IG>) {
    chomp;
    my @f = split /\t/;
    $id2symbol{ $f[1] } = $f[2];
}
close $IG or warn "$0 : failed to close input file '$fig' : $!\n";

my @dirs = glob "$di/*";
foreach my $dir (@dirs) {
    my $vid = basename($dir);
    my ( %adjp, %res, %count, $reps );
    my @fis = glob "$dir/deseq2/*/*";
    foreach my $fi (@fis) {
        my $bn = basename($fi);
        if ( $bn eq "deseq2_res.tab" ) {
            my $fip = "$fi";
            open my $IP, '<', $fip
              or die "$0 : failed to open input file '$fip' : $!\n";
            while (<$IP>) {
                unless (/^baseMean/) {
                    chomp;
                    my @f = split /\t/;
                    $res{ $f[0] } = join "\t", @f[ 2, 3, 5, 6 ];
                    $f[-1] = $f[-1] eq "NA" ? 999 : $f[-1];
                    $adjp{ $f[0] } = $f[-1];
                }
            }
            close $IP or warn "$0 : failed to close input file '$fip' : $!\n";
        }
        if ( $di =~ /salmon/ ) {
            if ( $bn eq "txi.abundances" ) {
                my $fic = "$fi";
                open my $IC, '<', $fic
                  or die "$0 : failed to open input file '$fic' : $!\n";
                while (<$IC>) {
                    unless (/^#/) {
                        chomp;
                        my @f = split /\t/;
                        if (/^ENS/) {
                            $count{ $f[0] } = join "\t", @f[ 1 .. $#f ];
                        }
                        else {
                            $reps = join "\t", @f;
                        }
                    }
                }
                close $IC
                  or warn "$0 : failed to close input file '$fic' : $!\n";
            }
        }
        else {
            if ( $bn eq "featureCounts.txt" ) {
                my $fic = "$fi";
                open my $IC, '<', $fic
                  or die "$0 : failed to open input file '$fic' : $!\n";
                while (<$IC>) {
                    unless (/^#/) {
                        chomp;
                        my @f = split /\t/;
                        if (/^Geneid/) {
                            $reps = join "\t", @f[ 6 .. $#f ];
                        }
                        else {
                            $count{ $f[0] } = join "\t", @f[ 6 .. $#f ];
                        }
                    }
                }
                close $IC
                  or warn "$0 : failed to close input file '$fic' : $!\n";
            }
        }
    }
    my $label = $di =~ /salmon/ ? "tpm" : "count";
    my $fo = "$do/deg_${vid}_$label.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "GeneID\tsymbol\tlog2FC\tlfcSE\tpvalue\tpadj\t$reps\n";
    foreach my $eid ( sort { $adjp{$a} <=> $adjp{$b} } keys %adjp ) {
        my $symbol = ( exists $id2symbol{$eid} ) ? $id2symbol{$eid} : $eid;
        print "$eid\t$symbol\t$res{$eid}\t$count{$eid}\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}
