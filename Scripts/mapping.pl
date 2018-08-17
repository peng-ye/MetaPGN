#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;

my ($help, $man) = (0, 0);
my %opts = (c => 0.9, i => 0.95, s => 'REF');

Getopt::Long::Configure("no_ignore_case");
GetOptions('help|?' => \$help, man => \$man,
    'cvg|c=f' => \$opts{c},
    'identity|i=f' => \$opts{i}, 'sample|s=s' => \$opts{s}
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;
pod2usage(1) unless(@ARGV == 3);

my %asm_gene;
open IN, $ARGV[1] or die "$! $ARGV[1]!\n";
while(<IN>) {
    my @t = split;
    next unless($t[3] == 1);
    $asm_gene{$t[0]}{$t[1]}{cid} = $t[2];
}

my %ref_gene;
open IN, $ARGV[2] or die "$! $ARGV[2]!\n";
while(<IN>) {
    my @t = split;
    my ($iden, $qcvg, $rcvg) = ($t[0]/($t[0]+$t[1]), ($t[0]+$t[1])/$t[10], ($t[0]+$t[1])/$t[14]);
    next if($iden<$opts{i} || ($qcvg<$opts{c} && $rcvg<$opts{c}));
  	#next if($ref_gene{$t[13]} && $ref_gene{$t[13]}{cvg} > $rcvg);###之前选最好的比对结果，但是现在不选了。
#	next if $t[9] =~ /^\d+\./;###filter bacteria result
#	die "error $_\n" unless $t[9] =~ /(\S+?)_(\S+)/;
#    my ($sample, $qgene) = $t[9] =~ /(\S+?)_(\S+)/;
	my ($sample,$qgene);
	if ($t[9]=~/^(\d+)\.(\S+)/){
		($sample,$qgene)=($1,$2);
	}
	elsif($t[9] =~ /\S+_gene_\S+/){
		($qgene, $sample) = $t[9] =~ /((\S+?)_gene_\S+)/;
	}
	else{
		die "error $_\n" unless $t[9] =~ /(\S+?)_(\S+)/;
		($sample,$qgene) = $t[9] =~ /(\S+?)_(\S+)/;
	}
#    $ref_gene{$t[13]}{cid} = $asm_gene{$sample}{$qgene}{cid};
#    $ref_gene{$t[13]}{cvg} = $rcvg;
#    $ref_gene{$t[13]}{rep} = 0;

	$ref_gene{$t[13]}{cid}{$asm_gene{$sample}{$qgene}{cid}}=$rcvg if !defined $ref_gene{$t[13]}{cid}{$asm_gene{$sample}{$qgene}{cid}};
	$ref_gene{$t[13]}{cid}{$asm_gene{$sample}{$qgene}{cid}}=$rcvg if $ref_gene{$t[13]}{cid}{$asm_gene{$sample}{$qgene}{cid}}<$rcvg;
	$ref_gene{$t[13]}{rep} = 0 if !defined $ref_gene{$t[13]}{rep};

}

my $cid = 0;
open IN, $ARGV[0] or die "$! $ARGV[0]!\n";
while(<IN>) {
    next unless(/^>/);
    my ($gene_id) = /^>(\S+)/;
    next if($ref_gene{$gene_id});
#    $ref_gene{$gene_id}{cid} = --$cid;
#    $ref_gene{$gene_id}{cvg} = 1;
    $ref_gene{$gene_id}{cid}{--$cid} = 1 ;
    $ref_gene{$gene_id}{rep} = 1;
}

foreach my $g(keys %ref_gene) {
	my @temp;
	foreach my $t(keys %{$ref_gene{$g}{cid}})
	{
		push @temp,$t;
	}
	print "$opts{s}\t$g\t".(join "|",@temp)."\t$ref_gene{$g}{rep}\n";
#    print "$opts{s}\t$g\t$ref_gene{$g}{cid}\t$ref_gene{$g}{rep}\n";
}

__END__

=head1 NAME

mapping.pl - this program is used to ...

=head1 SYNOPSIS

mapping.pl [OPTIONS] <in.ref.cds> <in.nrgc> <in.blat> >out.nrgc

=head1 OPTIONS

=over 8

=item B<-c, --cvg>=f

cutoff of coverage to either query or reference[0.9]

=item B<-i, --iden>=f

cutoff of identity[0.95]

=item B<-s, --sample>=s

sample name to the reference[REF]

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Full documentation

=back

=head1 DESCRIPTION

detailed description

=cut
