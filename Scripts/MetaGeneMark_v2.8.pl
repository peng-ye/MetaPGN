#!/usr/bin/perl -w
use strict;
use Getopt::Std;

my $bin_path = "";
$bin_path = $1 if ($0 =~ /^(.*\/)[^\/]+$/);

my $mgm_bin = $bin_path."basic_src/gmhmmp2.8";
my $mgm_mod = $bin_path."basic_src/MetaGeneMark_v1.mod";
my $deal_pre = "perl ".$bin_path."basic_src/deal_gmm_v2.8.pl";
my $transform = "perl ".$bin_path."basic_src/transform.pl";
my $codon = $bin_path."table/codon-table.11";

use vars qw($opt_i $opt_o $opt_s $opt_c $opt_M $opt_A);
getopts("i:o:s:c:M:A");

(defined $opt_i and defined $opt_o) or &usage();

my $fa = $opt_i;
my $out = $opt_o;
my $mark = "";
my $min_len = $opt_M || 0;
$mark = $opt_s."_" if ($opt_s);
$mark .= "GL";

$codon = $opt_c if (defined $opt_c and (-e $opt_c));

my $outpath = $out;
`mkdir -p $outpath` if ($outpath =~ s/\/[^\/]+$// and !(-e $outpath));

#step1: use MetaGeneMark product pre file

`$mgm_bin -m $mgm_mod -o $out.gmm $fa`;

#step2: deal the pre file, change to gff

`$deal_pre $out.gmm $fa $out $min_len $mark`;

#step3: transform

`$transform $codon $out.more$min_len.fa $out.more$min_len.pep` if ($opt_A);

sub usage
{
    print "\tUsage: ", $0, " options\n",
          "\toptions:\n",
          "\t\t-i <str>\tthe input fa file\n",
          "\t\t-o <str>\tthe ouput file prefix\n",
          "\t\t[-s <str>]\tset uniq prefix mark for one sample (default null)\n",
          "\t\t[-M <num>]\tthe gene min length(default 0)\n",
          "\t\t[-c <str>]\tthe codon table path (default codon table[11])\n",
          "\t\t[-A]\tset for output all include protein seq (default no)\n";
    exit(1);
}
