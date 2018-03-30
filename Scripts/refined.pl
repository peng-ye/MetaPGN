#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my ($help, $man) = (0, 0);
my %opts = (p => 'prefix');

Getopt::Long::Configure("no_ignore_case");
GetOptions('help|?' => \$help, man => \$man,
	'prefix|p=s' => \$opts{p}, 'coverage|c=i' => \$opts{c},
	'identity|i=i' => \$opts{i}, 'samples|s=i' => \$opts{s}
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;
pod2usage(1) unless(@ARGV);

my $count1 = 0;
my %node;
open IN, "$ARGV[0].node" or die "$! $ARGV[0].node!\n";
<IN>;
while(<IN>)  {
	++$count1;
	chomp;
	my @t = split "\t", $_;
	$node{$t[0]}{status} = $t[1];
	$node{$t[0]}{wt} = $t[2];
	$node{$t[0]}{order} = $t[3];
}
close IN;
print STDERR "$count1 all input\n";

my %edge;
open IN, "$ARGV[0].edge" or die "$! $ARGV[0].edge!\n";
<IN>;
while(<IN>) {
	my @t = split;
	my ($from, $to) = $t[0] lt $t[1] ? ($t[0], $t[1]) : ($t[1], $t[0]);
	$edge{$from}{$to}{status} = $t[2];
	$edge{$from}{$to}{wt} = $t[3];
	next if($t[0] eq $t[1]);
	if($edge{$from}{$to}{status} eq 3 ) {
		++$node{$from}{blued};	   ## on degree
		++$node{$to}{blued};
	} elsif($edge{$from}{$to}{status} eq 2){
		++$node{$from}{redd};	## not on degree
		++$node{$to}{redd};
	}elsif($edge{$from}{$to}{status} eq 1){
		++$node{$from}{greend};	   ## green degree
		++$node{$to}{greend};   
	}
	 
}
close IN;

foreach my $n(keys %node) {
	$node{$n}{blued} = 0 unless(exists $node{$n}{blued});
	$node{$n}{redd} = 0 unless(exists $node{$n}{redd});
	$node{$n}{greend} = 0 unless(exists $node{$n}{greend});
}
foreach my $f(keys %edge) {
	foreach my $t(keys %{$edge{$f}}) {
		next if($f eq $t);
		$edge{$t}{$f}{status} = $edge{$f}{$t}{status};
		$edge{$t}{$f}{wt} = $edge{$f}{$t}{wt};
	}
}

my $count = 0;
while(1) {
	foreach my $n(keys %node) {
		next unless($node{$n}{blued} + $node{$n}{redd} + $node{$n}{greend} == 1);
		my ($adj) = grep{$_ ne $n} keys %{$edge{$n}};
		if(exists $node{$adj}){
			next unless($node{$adj}{blued} + $node{$adj}{redd} + $node{$n}{greend} > 2);
		  	my $status = $edge{$n}{$adj}{status};
		  	delete $edge{$n}{$adj};
		  	delete $edge{$adj}{$n};
		  	delete $node{$n};
		  	delete $edge{$n}{$n} if($edge{$n}{$n});
		 	if($status eq 3 ){
				--$node{$adj}{blued};
		 	}elsif($status eq 2){
		   		--$node{$adj}{redd};
		 	}elsif($status eq 1){
		   		--$node{$adj}{greend};
		 	}
		  	++$count;
		  	print STDERR "tip\t$n\n";
	  	} 
	}
	last unless($count);
	print STDERR "$count tips removed!\n";
	$count = 0;
}

while(1) {
	foreach my $n(keys %node) {
		  next unless(
			(exists $node{$n})&&
			(exists $node{$n}{blued})&&
			(exists $node{$n}{redd})  &&
  			defined $node{$n} &&
			($node{$n}{blued} == 0 && $node{$n}{greend} == 0) &&
 			$node{$n}{redd} == 1);	  
		  ++$count;
		  my $prev = $n;
		  my ($next) = grep{$_ ne $n} keys %{$edge{$n}};
		  print STDERR "long_tips\t";
		  while((exists $node{$next})&& $node{$next}{redd} == 2 && $node{$next}{blued} == 0 && $node{$next}{greend} == 0) {
			 print STDERR "$prev,";
			 delete $node{$prev};
			 delete $edge{$prev}{$next};
			 delete $edge{$next}{$prev};
			 delete $edge{$prev}{$prev} if($edge{$prev}{$prev});
			 ($prev) = grep{$_ ne $next && $_ ne $prev} keys %{$edge{$next}};
			 ($prev, $next) = ($next, $prev);
			 $count++;
		 }		   
		 print STDERR "$prev long\n";
		 delete $node{$prev};
		 delete $edge{$prev}{$next};
		 delete $edge{$next}{$prev};
		 delete $edge{$prev}{$prev} if($edge{$prev}{$prev});
		 --$node{$next}{redd};
	}
	last unless($count);
	print STDERR "$count long red tips removed!\n";
	$count = 0;
}
$count = 0;
foreach my $f(keys %edge) {
	foreach my $t(keys %{$edge{$f}}) {
		next unless($edge{$f}{$t});
		next unless($edge{$f}{$t}{status} == 2 && $node{$f}{status} == 3 && $node{$t}{status} == 2);
		my %stat;
		my @tips = ($t);
		my $exception = 0;  ## whether the red nodes cluster comform to the regulation
		while(@tips) {
			my $seed = shift @tips;
			if($node{$seed}{status} == 3) {
				$exception = 1;
				last;
			}
			$stat{$seed} = 1;
			foreach my $o(keys %{$edge{$seed}}) {
				next if($stat{$o});
				if($edge{$seed}{$o}{status} == 3) {
					$exception = 1;
					last;
				} elsif($o ne $f) {
					push @tips, $o;
				}
			}
			last if($exception);
		}
		next if($exception);
		print STDERR  "red_cluster\t";
		print STDERR join ",", keys %stat;
		print STDERR "\n";
		foreach my $k(keys %stat) {
			foreach my $o(keys %{$edge{$k}}) {
				delete $edge{$k}{$o};				
			}
			delete $node{$k};
		}
		foreach my $o(keys %{$edge{$f}}) {
			next unless($stat{$o});			
			delete $edge{$f}{$o};
		}
		++$count;
	}
}
print STDERR "$count candidates!\n";

my $count2 = 0;
open OUT, ">$opts{p}.node" or die "$! $opts{p}!\n";
print OUT "idx\tstatus\twt\torder\tblued\tredd\tgreend\n";
foreach my $k(keys %node) {
	if((exists $node{$k}{status})&&(exists $node{$k}{wt})&&(exists $node{$k}{order})){
		++$count2;
		print OUT "$k\t$node{$k}{status}\t$node{$k}{wt}\t$node{$k}{order}\t";
		print OUT "$node{$k}{blued}\t$node{$k}{redd}\t$node{$k}{greend}\n";	 
	}else {
		print OUT ""; 
   }	 
}
close OUT;
print STDERR "$count2 leave now\n"; 

open OUT, ">$opts{p}.edge" or die "$! $opts{p}!\n";
print OUT "source\ttarget\tstatus\twt\n";
foreach my $f(keys %edge) {
	my $flabel = $node{$f}{ncid} ? $node{$f}{ncid} : $f;
	foreach my $t(keys %{$edge{$f}}) {
		next if($f gt $t);
		next if($node{$f}{ncid} && $node{$t}{ncid});
		my $tlabel = $node{$t}{ncid} ? $node{$t}{ncid} : $t;
		print OUT "$flabel\t$tlabel\t$edge{$f}{$t}{status}\t$edge{$f}{$t}{wt}\n";
	}
}
close OUT;
=cut

__END__

=head1 NAME

refine.pl - this program is used to removing closed sub-networks and tips in which a gene links with only one different gene.

=head1 SYNOPSIS

refine.pl [options] <in prefix of node/edge>

=head1 OPTIONS

=over 8

=item B<-p, --prefix>

output file prefix, must not be the same as in.prefix [prefix]

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Full documentation

=back

=head1 DESCRIPTION

detailed description

=cut
