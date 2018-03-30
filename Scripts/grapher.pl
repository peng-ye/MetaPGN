#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my ($help, $man) = (0, 0);
my %opts = (p => 'prefix', s => '', c => 3, r => 0.5);

Getopt::Long::Configure("no_ignore_case");
GetOptions('help|?' => \$help, man => \$man,
	'sample|s=s' => \$opts{s}, 'prefix|p=s' => \$opts{p},
	'count|c=i' => \$opts{c}, 'ratio|r=f' => \$opts{r}
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;
pod2usage(1) unless(@ARGV == 2);

my %samples;
if($opts{s}) {
	open IN, $opts{s} or die "$! $opts{s}!\n";
	while(<IN>) {
		my @t = split;
		$samples{$t[0]} = 1;
	}
	close IN;
}

my %node;
my %edge;
my $order = 0;
open IN, $ARGV[1] or die "$! $ARGV[1]!\n";
while(<IN>) {
	my @t = split;
	my @f = split ",", $t[3];
	for (my $i = 0 ; $i < @f ; ++$i) {
		my @temp = split /\|/,$f[$i];
		++$order;
		foreach (@temp) {
			++$node{$_}{wt};
			$node{$_}{status} |= 0x01;
			$node{$_}{order} = $order unless defined $node{$_}{order};
		}
		if ($i > 0) {
			my @last = split /\|/,$f[$i-1];
			foreach my $p (@temp) {
				foreach my $q (@last) {
					my ($from, $to) = ($q, $p);
					($from, $to) = ($to, $from) if($from gt $to);
					++$edge{$from}{$to}{wt};
					$edge{$from}{$to}{status} |= 0x01;
				}
			}
		}
	}
}

open IN, $ARGV[0] or die "$! $ARGV[0]!\n";
while(<IN>) {
	my @t = split;
	next if(%samples && !$samples{$t[0]});
	next if($t[2] < $opts{c});
	my @f = split ",", $t[3];
	my $valid_count = 0;
	for(my $i = 0; $i < @f; ++$i) {
		++$valid_count if($node{$f[$i]} && ($node{$f[$i]}{status} & 0x01));
	}
	next if($valid_count / @f < $opts{r});
	++$node{$f[0]}{wt};
	$node{$f[0]}{status} |= 0x02;
	for(my $i = 1; $i < @f; ++$i) {
		++$node{$f[$i]}{wt};
		$node{$f[$i]}{status} |= 0x02;
		my ($from, $to) = ($f[$i-1], $f[$i]);
		($from, $to) = ($to, $from) if($from gt $to);
		++$edge{$from}{$to}{wt};
		$edge{$from}{$to}{status} |= 0x02;
	}
}
close IN;

foreach my $n(keys %node) {
	$node{$n}{order} = 0 unless($node{$n}{order});
}

open OUT, ">$opts{p}.node" or die "$! $opts{p}.node!\n";
print OUT "#id\tstatus\twt\torder\n";
foreach my $n(keys %node) {
	print OUT "$n\t$node{$n}{status}\t$node{$n}{wt}\t$node{$n}{order}\n";
}
open OUT, ">$opts{p}.edge" or die "$! $opts{p}.edge!\n";
print OUT "#source\ttarget\tstatus\twt\n";
foreach my $f(keys %edge) {
	foreach my $t(keys %{$edge{$f}}) {
		print OUT "$f\t$t\t$edge{$f}{$t}{status}\t$edge{$f}{$t}{wt}\n";
	}
}
close OUT;

=cut

__END__

=head1 NAME

grapher.pl - this program is used to ...

=head1 SYNOPSIS

grapher.pl [options] <query.ssgc> <ref.ssgc>

=head1 OPTIONS

=over 8

=item B<-p, --prefix>

output file prefix[prefix]

=item B<-c, --count>

the count of genes in an assembly at least has[3]

=item B<-r, --ratio>

the ratio that shared genes (can be found in the reference genome) should account for all genes an assembly contains [0.5]

=item B<-s, --samples>

sample file list to be as assembly result[]

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Full documentation

=back

=head1 DESCRIPTION

detailed description

=cut
