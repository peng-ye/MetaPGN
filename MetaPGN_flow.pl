#!/usr/Scripts/perl -w
use strict;
use Getopt::Long;
use Pod::Text;
use FindBin qw/$Bin/;

my $type = "nt";
my $query_type = "genome";
my $gene = "assembly";
my $min_gene_len = 100;
my $coverage;
my $identity;
my $count = 3;
my $ratio = 0.5;
my $n;
my $d = 0;
my $g = 1;
my $T = 6;
my $G = 0;
my $div = 10;
my $qsub = "local";
my $qsp = "";
my $qsq = "";
my ($query_assemblies,$reference,$metadata,$output_prefix,$help);
GetOptions(
    "type:s"=>\$type,
    "q:s" =>\$query_assemblies,
    "qt:s" =>\$query_type,
    "gene:s"=>\$gene,
    "ref:s" =>\$reference,
    "p:s" =>\$output_prefix,
    "meta:s"=>\$metadata,
    "M:s" =>\$min_gene_len,  
    "div:s"=>\$div,
    "aS:s"=>\$coverage,
    "n:s" =>\$n,
    "d:s" =>\$d,
    "g1:s" =>\$g,
    "T:s" =>\$T,
    "G:s" =>\$G,
    "i:s" =>\$identity,
    "c:s" =>\$count,
    "r:s"=>\$ratio,
    "qs:s"=>\$qsub,
    "qsp:s" =>\$qsp,
    "qsq:s" =>\$qsq,
    "h:s" =>\$help,
        );

do{&usage;exit(1);} if ($help || !defined($query_assemblies || $query_type || $reference || $output_prefix) || !defined($query_assemblies));
#========================Program Path List=================================================
my $MGM="$Bin/Scripts/MetaGeneMark_flow.pl";
my $cdhit_para="$Bin/Scripts/cd-hit-para.pl";
my $cdhit_div="$Bin/Scripts/cd-hit-div";
my $cdhit_est="$Bin/Scripts/cd-hit-est";
my $cdhit="$Bin/Scripts/cd-hit";
my $cdhit_clstr2tbl="$Bin/Scripts/cdhit_clstr2tbl.pl";
my $cds2ssgc="$Bin/Scripts/cds2ssgc.pl";
my $blat="$Bin/Scripts/blat";
my $blat_filter="$Bin/Scripts/blat_filter.pl";
my $mapping="$Bin/Scripts/mapping.pl";
my $cds2ssgc_ref="$Bin/Scripts/cds2ssgc_ref.pl";
my $grapher="$Bin/Scripts/grapher.pl";
my $refine="$Bin/Scripts/refined.pl";
my $add_K12="$Bin/Scripts/add_annotation_K12.pl";

print "time=\$(date \"+%Y-%m-%d %H:%M:%S\")\n";
print "echo \"\${time}\"\n";
print "echo \"Welcome to MetaPGN! The program begins...\"\n";

if($gene eq "gene"){
    print "echo \"NOTE: The input is gene sequence;\"\n";
    print "echo \"We will skip the Step1. Gene prediction.\"\n";
    if($query_assemblies=~/list$/){
        my $files;
        open TMPIN, $query_assemblies;
        while(<TMPIN>){
            chomp;
            $files .= " $_";
        }
        close TMPIN;
        print "cat $files > $output_prefix.predict.more${min_gene_len}.fa\n";
    } else {
        print "ln -s $query_assemblies $output_prefix.predict.more${min_gene_len}.fa\n";
    }
}
elsif($gene eq "assembly"){
    if($type eq "nt"){
        print "echo \"NOTE: The input is assembly;\"\n";
        print "echo \"# Step1. Gene prediction.\"\n";
        if($query_assemblies=~/list$/){
            my $gene_files;
            open TMPIN, $query_assemblies;
            while(<TMPIN>){
                chomp;
                my $prefix = $_;
                $prefix =~ s/.+\///;
                print "$MGM -i $_ -o $prefix.predict -s $prefix.predict -M $min_gene_len 2>>gene_prediction.log\n";
                $gene_files .= " $prefix.predict.more${min_gene_len}.fa";
            }
            close TMPIN;
            print "cat $gene_files > $output_prefix.predict.more${min_gene_len}.fa\n";
        } else {
            print "$MGM -i $query_assemblies -o $output_prefix.predict -s $output_prefix.predict -M $min_gene_len 2>gene_prediction.log\n";
        }
    }
    elsif($type eq "aa"){
        print STDERR "Sorry! The input sequence type is aa, please set -gene gene.\n";
        exit(1);
    }
    else{
        print STDERR "Sorry! The input sequence type is aa, please set -gene gene.\n";
        exit(1);    
    }
}
else{
    print STDERR "Sorry! The input sequence type is unknown! Please check it again! You can choose -gene gene or -gene assembly.\n";
    &usage;exit(1);
}

if($qsub eq "local"){
    print "echo \"# Step2. Gene redundancy elimination.\"\n";
        print "$cdhit_div -i $output_prefix.predict.more${min_gene_len}.fa -o $output_prefix.sort.fasta -div 1 >cd-hit-div.log\n";
        if($type eq "nt"){
            $n = 8 unless(defined($n)); $coverage = 0.9 unless(defined($coverage)); $identity = 0.95 unless(defined($identity));
            print "echo \"Your input sequence type is nucleotide sequence (-type nt).\"\n";
            print "$cdhit_est -i $output_prefix.sort.fasta-* -o $output_prefix.cov${coverage}_id${identity}.fasta -n $n -d $d -g $g -T $T -G $G -aS $coverage -c $identity >cd-hit-est.log\n";
        }
        elsif($type eq "aa"){
            print "echo \"Your input sequence type is amino acid sequence (-type aa).\"\n";
            $n = 5 unless(defined($n)); $coverage = 0.7 unless(defined($coverage)); $identity = 0.7 unless(defined($identity));
            print "$cdhit -i $output_prefix.sort.fasta-* -o $output_prefix.cov${coverage}_id${identity}.fasta -n $n -d $d -g $g -T $T -G $G -aS $coverage -c $identity >cd-hit-est.log\n"
        }
        else{
            print STDERR "Sorry! The input sequence type is unknown! Please check it again! You can choose -type aa or -type nt.\n";
            exit(1);
        }
}
elsif($qsub eq "qsub"){
    print "echo \"# Step2. Gene redundancy elimination.\"\n";
    if($type eq "nt"){
        $n = 8 unless(defined($n)); $coverage = 0.9 unless(defined($coverage)); $identity = 0.95 unless(defined($identity));
        print "echo \"Your input sequence type is nucleotide sequence (-type nt).\"\n";
        print "echo \"We will qsub your program now...\"\n";
        print "perl $cdhit_para -i $output_prefix.predict.more${min_gene_len}.fa -o $output_prefix.cov${coverage}_id${identity}.fasta --Q @{[($div+1)*$div/2+1]} --T SGE --S $div --P cd-hit-est --q $qsq --p $qsp --m 2.5G --t $T -n $n -G $G -aS $coverage -c $identity -M 0 -d $d -r 1 -g $g -T $T\n";    
    }
    elsif($type eq "aa"){
        print "echo \"Your input sequence type is amino acid sequence (-type aa).\"\n";
        print "echo \"We will qsub your program now...\"\n";
        $n = 5 unless(defined($n)); $coverage = 0.7 unless(defined($coverage)); $identity = 0.7 unless(defined($identity));
        print "perl $cdhit_para -i $output_prefix.predict.more${min_gene_len}.fa -o $output_prefix.cov${coverage}_id${identity}.fasta --Q @{[($div+1)*$div/2+1]} --T SGE --S $div --q $qsq --p $qsp --m 2G --t $T --P cd-hit -n $n -G $G -aS $coverage -c $identity -M 0 -d $d -g $g -T $T\n";
    }
    else{
        print STDERR "Sorry! The input sequence type is unknown! Please check it again! You can choose -type aa or -type nt.\n";
        &usage; exit(1);
    }
}
else{
    print STDERR "Sorry! The -qs type is unknown! Please check it again! You can choose -qs qsub or -qs local.\n";
    exit(1);
}

print "echo \"# Step3. Gene type determination, pairwise gene adjacency extraction, and assembly recruitment.\"\n";
print "perl $cdhit_clstr2tbl $output_prefix.cov${coverage}_id${identity}.fasta.clstr > $output_prefix.nrgc 2>$output_prefix.nrgc.log\n";
print "perl $cds2ssgc $output_prefix.predict.more${min_gene_len}.fa $output_prefix.nrgc >$output_prefix.ssgc 2> cds2ssgc.error.log\n";
print "$blat -noHead -noTrimA $reference $output_prefix.cov${coverage}_id${identity}.fasta $output_prefix.ref_cds.blat\n";
if ($query_type eq "metagenome") {
    print "awk '{print \$3,\$1\"_\"\$2}' $output_prefix.nrgc >genes.name.num.list\n";
    print "perl $blat_filter -c $count -r $ratio genes.name.num.list $output_prefix.ref_cds.blat $output_prefix.ssgc >$output_prefix.ref_cds.blat_c3r0.5_f\n";
    print "perl $mapping -s K12 $reference $output_prefix.nrgc $output_prefix.ref_cds.blat_c3r0.5_f >K12.nrgc\n";
} else {
    print "perl $mapping -s K12 $reference $output_prefix.nrgc $output_prefix.ref_cds.blat >K12.nrgc\n";
}
print "perl $cds2ssgc_ref $reference K12.nrgc K12 >K12.ssgc 2>K12.ssgc.error.log\n";
print "echo \"# Step4. Pangenome network generation.\"\n";
if($query_type eq "metagenome"){
    print "$grapher -c $count -r $ratio -p $output_prefix $output_prefix.ssgc K12.ssgc\n";
}
elsif($query_type eq "genome"){
    $count = 1;
    $ratio = 0;
    print "$grapher -c $count -r $ratio -p $output_prefix $output_prefix.ssgc K12.ssgc\n";
}
else{
    print STDERR "Sorry! The -qt type is unknown! Please check it again! You can choose -qt genome or -qt metagenome.\n";
    exit(1);
}
print "perl $refine -p $output_prefix.notips $output_prefix 2>$output_prefix.notips.log\n";
if(defined($metadata)){
    print "echo \"# Step5. Annotation for reference genes [optional]\"\n";
    print "perl $add_K12 -p $output_prefix.notips.addRef -n $output_prefix.notips.node -re $metadata >$output_prefix.notips.addRef.log 2>$output_prefix.notips.addRef.error.log\n";
    print "echo \"The program ends now.\nPlease check your results at:\n  $output_prefix.notips.addRef.node\n  $output_prefix.notips.edge\"\n";
} else {
    print "echo \"The program ends now.\nPlease check your results at:\n  $output_prefix.notips.node\n  $output_prefix.notips.edge\"\n";
}
print "time=\$(date \"+%Y-%m-%d %H:%M:%S\")\n";
print "echo \"\${time}\"\n";

sub usage {
    print <<EOD;

Description: This script is used for generating a pipeline for construction of pangenome networks.
Version 1.0 Aug 1, 2018   Author: Shanmei Tang, Ye Peng, Dan Wang
Usage: perl MetaPGN_flow.pl -q <input query assemblies sequence> -qt <input query assemblies type> -ref <input reference sequence> -p <output prefix> <Other options> >work.sh

Options
                -type <str>   sequence type of input query assemblies, nt (nucleotide sequence) or aa (amino acid sequence), (default nt)
                -q    <str>   input file (in FASTA format) or file list (with the suffix .list) for query sequences
                -qt   <str>   source of the input sequence, genome or metagenome (default genome)
                -gene <str>   type of the input sequence, gene or assembly (default assembly)
                -ref  <str>   input file (in FASTA format) for the reference sequence
                -meta <str>   input file (in metadata format) for metadata of the reference sequence
                -p    <str>   output prefix
                -M    <int>   minimum gene length in gene prediction (default 100)
                -qs   <str>   qsub or local, when run the Step2. Gene redundancy elimination (default local)
                -qsp  <str>   project name for qsub -P (default none)
                -qsq  <str>   queue name for qsub -q (default none)
                -div  <int>   when you choose -qs qsub, it will divide your gene prediction results into segment (default 10)
                -aS   <float> alignment coverage for the shorter sequence (default, nt: 0.9, aa: 0.7)
                                if set to 0.9, the alignment must cover 90% of the sequence
                -i    <float> sequence identity threshold (default, nt: 0.95, aa: 0.7. See Cd-hit manual for more details)
                -n    <int>   word_length (default nt: 8, aa: 5. See Cd-hit manual for more details)
                -d    <int>   length of description in the *.clstr file (default 0)
                                if set to 0, it takes the fasta defline and stops at first space (See Cd-hit manual for more details)
                -g1   <int>   1 or 0 (default 1)
                                Based on cd-hit's default algorithm, a sequence is clustered to the first cluster that meet the threshold (fast cluster). If set to 1, the program will cluster it into the most similar cluster that meet the threshold (accurate but slow mode) but either 1 or 0 won't change the representatives of final clusters (See Cd-hit manual for more details)
                -T    <int>   number of threads in cd-hit-est, with 0, all CPUs will be used (default 6. See Cd-hit manual for more details)
                -G    <int>   use global sequence identity (default 0. See Cd-hit manual for more details)
                -c    <int>   cut off for the gene count on an assembly (default 3)
                -r    <float> cut off for the ratio of the number of shared genes on an assembly to the total number of genes on that assembly (default 0.5)
                -h    <str>   display this help text and exit

Examples
    Example 1, the input sequence is nucleotide sequence of assemblies from metagenomes:
        perl MetaPGN_flow.pl -q Inputs/query.assemblies.list -qt metagenome -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.fasta -meta References/Annotations/Escherichia_coli_K_12_substr__MG1655.idx.metadata -p metagenome_assemblies_nt > MetaPGN.sh

    Example 2, the input sequence is nucleotide sequence of genes from isolated genomes:
        perl MetaPGN_flow.pl -q Inputs/genes/query.genes.nt.fasta -qt genome -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.fasta -p genome_genes_nt -gene gene > MetaPGN.sh

    Example 3, the input sequence is amino acid sequence of genes from metagenomes, and the script will use qsub to submit tasks in redundancy elimination of genes onto available computing clusters:
        perl MetaPGN_flow.pl -q Inputs/query.genes.aa.list -qt metagenome -type aa -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.prot.fasta -meta References/Annotations/Escherichia_coli_K_12_substr__MG1655.prot.idx.metadata -gene gene -qs qsub -div 3 -p genome_genes_aa > MetaPGN.sh
EOD
exit(1);
}

