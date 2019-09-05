#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $dio = $ARGV[0];

my %hash;
my $fi = "$dio/gencode.gtf";
open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
while (<$I>) {
    unless (/^#/) {
        chomp;
        my @f = split /\t/;
        if ( $f[2] eq "transcript" ) {
            if ( $f[-1] =~
/gene_id\s+"(.+?)";\s+transcript_id\s+"(.+?)";.+?gene_name\s+"(.+?)";/
              )
            {
                my $key = join "\t", $2, $1, $3;
                $hash{$key} = 1;
            }
        }
    }
}
close $I or warn "$0 : failed to close input file '$fi' : $!\n";

my $fo = "$dio/gencode_id2symbol.txt";
open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
foreach my $key ( sort keys %hash ) {
    print "$key\n";
}
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

