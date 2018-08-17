#!/usr/bin/perl -w
use strict;

die "Usage: $0 <input.cds> <input.nrgc> <sample_id> >out.ssgc\n" unless(@ARGV == 3);

my ($cds, $nrgc, $sample) = @ARGV;

my %gene;
open IN, $nrgc or die "$! $nrgc!\n";
while(<IN>) {
    my @t = split;
    $gene{$t[0]}{$t[1]} = $t[2];
}

my %contig;
my($contig_id,$from,$to);

open IN, $cds or die "$! $cds!\n";
while(<IN>) {
    next unless(/^>/);
    my ($gene_id) = /^>(\S+)/;
#    my ($contig_id, $from, $to) = $gene_id =~ /(\S+?):c?(\d+)-(\d+)/;
#	my($contig_id,$from,$to)= /^>(\S+)_cdsid_.*(\d+)\.\.(\d+)/;  #v2版本的错误
	if(/location/){
		s/complement|\(|\)//g if /complement/;
		s/join|\(|\)//g if /join/;
		($contig_id,$from,$to)= /^>(\S+)_gene.*?location=(\d+)\..*\.(\d+)/;
	}
	# print "$contig_id\t$from\t$to\n";
    ($from, $to) = ($to, $from) if($from > $to);
    my $cluster_id = $gene{$sample}{$gene_id};
	# print "contig=$contig_id\t$from\t$to\n";
    push @{$contig{$sample}{$contig_id}}, [$cluster_id, $from];
}
#exit;
foreach my $s(keys %contig) {
    foreach my $c(keys %{$contig{$s}}) {
        my @order = map{$_->[0]} sort{$a->[1] <=> $b->[1]} @{$contig{$s}{$c}};
        my $count = @order;
        print "$s\t$c\t$count\t";
        print join ",", @order;
        print "\n";
    }
}
