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
while(<IN>) {
	++$count1;
    	chomp;
    	my @t = split "\t", $_;    
    	if($t[0] eq ""){
    		print STDERR "$count1 is erro line\n";
    	}    
    	$node{$t[0]}{status} = $t[1];
    	$node{$t[0]}{wt} = $t[2];
    	$node{$t[0]}{order} = $t[3];
    	$node{$t[0]}{blued} = $t[4];
    	$node{$t[0]}{redd} = $t[5];
    	$node{$t[0]}{greend} = $t[6];
}
print STDERR "$count1 all input\n";


#five
my %node2;
my $extra_pro_file5 = "Data/Escherichia_coli_K_12_substr__MG1655.idx.metadata";
open IN, "$extra_pro_file5" or die "$! $extra_pro_file5!\n";
while(<IN>) {
    	chomp;
    	my @t = split "\t", $_;
    	$t[0]=~s/^e//;
	$node2{$t[0]}{gene} = $t[2];
    	$node2{$t[0]}{protein} = $t[3];
    	$node2{$t[0]}{pid} = $t[4];
    	$node2{$t[0]}{len2} = $t[6]-$t[5]+1;
	$node2{$t[0]}{complement} = $t[7];
	$node2{$t[0]}{note} = $t[8];
	$node2{$t[0]}{gene} ||= "unknown";
    	$node2{$t[0]}{protein} ||= "unknown";
    	$node2{$t[0]}{pid} ||= "unknown";
    	$node2{$t[0]}{len2} ||= "unknown";
	$node2{$t[0]}{complement} ||= "unknown";
	$node2{$t[0]}{note} ||= "unknown";
}

my $count2 = 0;
open OUT, ">$opts{p}.node" or die "$! $opts{p}!\n";
print OUT "idx\tstatus\twt\torder\tblued\tredd\tgreend\tgeneName\tprotein\tpid\trlen\tcomplement\tnote\n";
foreach my $k(keys %node) {
	++$count2;
     	if(exists $node2{$node{$k}{order}} && exists $node{$k}{order} &&  exists $node{$k}){
        	print OUT "$k\t$node{$k}{status}\t$node{$k}{wt}\t$node{$k}{order}\t$node{$k}{blued}\t$node{$k}{redd}\t$node{$k}{greend}\t$node2{$node{$k}{order}}{gene}\t$node2{$node{$k}{order}}{protein}\t$node2{$node{$k}{order}}{pid}\t$node2{$node{$k}{order}}{len2}\t$node2{$node{$k}{order}}{complement}\t$node2{$node{$k}{order}}{note}\n";
    	}
    	elsif(exists $node{$k}{order}){
        	print OUT "$k\t$node{$k}{status}\t$node{$k}{wt}\t$node{$k}{order}\t$node{$k}{blued}\t$node{$k}{redd}\t$node{$k}{greend}\tunknown\tunknown\tunknow\tunknown\tunknown\tunknown\n";
    	}

}
print STDERR "$count2 output\n"; 
