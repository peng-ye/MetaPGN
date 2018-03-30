#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my $help = 0;
my %opts = ( s => '', c => 3, r => 0.5 , cvg => 0.9, i => 0.95);

Getopt::Long::Configure("no_ignore_case");
GetOptions(
	'help|?' => \$help, 
	'sample|s=s' => \$opts{s}, 
	'cvg=f' => \$opts{cvg},'identity|i=f' => \$opts{i},
	'cutoff|c=i' => \$opts{c}, 'gts|r=f' => \$opts{r}
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(1) unless(@ARGV == 3);

my %samples;
if($opts{s}) {
	open IN, $opts{s} or die "$! $opts{s}!\n";
	while(<IN>) {
		my @t = split;
		$samples{$t[0]} = 1;
    	}
    	close IN;
}

my %id;
open IN,"$ARGV[0]" or  die "$! $ARGV[0]!\n";
while(<IN>) {
	chomp;
	my @t = split;
	$id{$t[1]} = $t[0];
}
close IN;

my (%blat,%flag);
open IN,"$ARGV[1]" or die "$! $ARGV[1]!\n";
while(<IN>) {
	my @t=split;
	my ($iden, $qcvg, $rcvg) = ($t[0]/($t[0]+$t[1]), ($t[0]+$t[1])/$t[10], ($t[0]+$t[1])/$t[14]);
	next if($iden<$opts{i} || ($qcvg<$opts{cvg} && $rcvg<$opts{cvg}));
	die "Can't find gene ID,Gene: $t[1]\n" if !defined $id{$t[9]};
	$blat{$id{$t[9]}} = "" if !defined $blat{$t[9]};
	$blat{$id{$t[9]}}.= $_;
	$flag{$id{$t[9]}} = 0;
}
close IN;

open IN,"$ARGV[2]" or die "$! $ARGV[2]!\n";
while(<IN>) {
	my @t = split;
	next if(%samples && !$samples{$t[0]});
	next if($t[2] < $opts{c});
	my @f = split ",", $t[3];
	my $valid_count = 0;
	for(my $i = 0; $i < @f; ++$i) {
		++$valid_count if defined $flag{$f[$i]};
	}
	next if($valid_count / @f < $opts{r});
	for(my $i = 0; $i < @f; ++$i) {
		$flag{$f[$i]} = 1 if defined $flag{$f[$i]};
	}
}
close IN;

foreach my $key(keys %flag)
{
	print $blat{$key} if $flag{$key}==1;
}
