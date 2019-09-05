#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;

my $dig = $ARGV[0];                             # reference folder
my $wd  = $ARGV[1];                             # work folder
my $diw = "$wd/RNACocktail_work/salmon_smem";

my $doo = "$wd/expression";
mkdir $doo unless -d $doo;
my $do = "$doo/salmon";
mkdir $do unless -d $do;

my %t2g;
my $fig = "$dig/gencode_id2symbol.txt";
open my $IG, '<', $fig or die "$0 : failed to open input file '$fig' : $!\n";
while (<$IG>) {
    chomp;
    my @f = split /\t/;
    $t2g{ $f[0] } = join "\t", @f[ 1, 2 ];
}
close $IG or warn "$0 : failed to close input file '$fig' : $!\n";

my @sids;
my %exp;
my @dirs = glob "$diw/*";
foreach my $dir (@dirs) {
    my $sid = basename($dir);
    push @sids, $sid;
    my $fi = "$dir/quant.sf";
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        unless (/^Name/) {
            chomp;
            my @f = split /\t/;
            $exp{ $f[0] }->{$sid} = $f[3];
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";
}

my $fo = "$do/salmon_tpm_tx.txt";
open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
print "txID\tgeneID\tsymbol\t";
print join "\t", @sids;
print "\n";
foreach my $tx ( sort keys %exp ) {
    print "$tx\t$t2g{$tx}";
    my %tmp = %{ $exp{$tx} };
    foreach my $sid (@sids) {
        print "\t$exp{$tx}->{$sid}";
    }
    print "\n";
}
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

