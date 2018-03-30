#!/usr/bin/perl -w
use strict;

die "Usage: $0 <input.cds> <input.nrgc> >out.ssgc\n" unless(@ARGV == 2);

my %gene;
open IN, $ARGV[1] or die "$! $ARGV[1]!\n";
while(<IN>) {
	my @t = split;
	$gene{$t[0]}{$t[1]} = $t[2];
}
my ($contig_id,$from,$to,$gene_id, $sample_id);
my %contig;
open IN, $ARGV[0] or die "$! $ARGV[0]!\n";
while(<IN>) {
	next unless(/^>/);
	if(/_gene/){
		($gene_id, $sample_id) = /^>((\S+?)_gene\S+)/;
		s/\.\.>/\.\./g  if /\.\.>/;
        	s/complement|\(|\)//g if /complement/;
        	s/join|\(|\)//g if /join/;
        	s/=</=/g if /=/;
        	($contig_id,$from,$to)= /^>(\S+)_gene.*?location=(\d+)\..*\.(\d+)/;
	}
	elsif(/_GL\d+/){
		my @t =split "  " ,$_;
        	$t[0]=~/^>(\S+)_(GL\d+)/;
        	($sample_id, $gene_id) = ($1,$2);
        	$t[2] =~ /locus=(\S+):(\d+):(\d+):\S+/;
        	($contig_id,$from,$to)= ($1,$2,$3);
	}
	else{
		($sample_id, $gene_id) = /^>(\S+?)_(\S+)/;
		($contig_id, $from, $to) = /locus=(\S+?):(\d+):(\d+):/;
	}
	($from, $to) = ($to, $from) if($from > $to);
	my $cluster_id = $gene{$sample_id}{$gene_id};
	push @{$contig{$sample_id}{$contig_id}}, [$cluster_id, $from];
}

foreach my $s(keys %contig) {
    foreach my $c(keys %{$contig{$s}}) {
        my @order = map{$_->[0]} sort{$a->[1] <=> $b->[1]} @{$contig{$s}{$c}};
        my $count = @order;
        print "$s\t$c\t$count\t";
        print join ",", @order;
        print "\n";
    }
}
