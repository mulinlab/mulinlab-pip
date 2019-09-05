#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;

my $dig = $ARGV[0];                           # reference folder
my $wd  = $ARGV[1];                           # work folder
my $diw = "$wd/RNACocktail_work/stringtie";

my $doo = "$wd/expression";
mkdir $doo unless -d $doo;
my $do = "$doo/stringtie";
mkdir $do unless -d $do;

my @sids;
my %fpkm;
my %tpm;
my @dirs = glob "$diw/*";
foreach my $dir (@dirs) {
    my $sid = basename($dir);
    push @sids, $sid;
    my $fi = "$dir/gene_abund.tab";
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        if (/^ENS/) {
            chomp;
            my @f = split /\t/;
            my $g = join "\t", @f[ 0, 1 ];
            $fpkm{$g}->{$sid} = $f[7];
            $tpm{$g}->{$sid}  = $f[8];
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";
}

my $fof = "$do/stringtie_fpkm_gene.txt";
open my $OF, '>', $fof or die "$0 : failed to open output file '$fof' : $!\n";
select $OF;
print "geneID\tsymbol\t";
print join "\t", @sids;
print "\n";
foreach my $g ( sort keys %fpkm ) {
    print "$g";
    my %tmp = %{ $fpkm{$g} };
    foreach my $sid (@sids) {
        print "\t$fpkm{$g}->{$sid}";
    }
    print "\n";
}
close $OF or warn "$0 : failed to close output file '$fof' : $!\n";

my $fot = "$do/stringtie_tpm_gene.txt";
open my $OT, '>', $fot or die "$0 : failed to open output file '$fot' : $!\n";
select $OT;
print "geneID\tsymbol\t";
print join "\t", @sids;
print "\n";
foreach my $g ( sort keys %tpm ) {
    print "$g";
    my %tmp = %{ $tpm{$g} };
    foreach my $sid (@sids) {
        print "\t$tpm{$g}->{$sid}";
    }
    print "\n";
}
close $OT or warn "$0 : failed to close output file '$fot' : $!\n";
