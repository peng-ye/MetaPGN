#!/usr/bin/perl -w
use strict;
################################################################################
unless(3==@ARGV) {
    &usage;
    exit;
}
################################################################################
my($codon,$seq_fa,$seq_pep)=@ARGV;
my(%encodon,%code,$aas,$start,$base1,$base2,$base3);
my(@info,@arry,$seq,$pep,$i,$temp);
################################################################################
open IN,$codon or die "read $codon $!\n";
while(<IN>) {
    chomp;
    if(/^AAs\s+=\s+(\S+)$/) {
        $aas=$1;
    }elsif(/^Starts\s+=\s+(\S+)$/) {
        $start=$1;
    }elsif(/^Base1\s+=\s+(\S+)$/) {
        $base1=$1;
    }elsif(/^Base2\s+=\s+(\S+)$/) {
        $base2=$1;
    }elsif(/^Base3\s+=\s+(\S+)$/) {
        $base3=$1;
    }else {
        print STDERR "\nError in $codon ,please check!\n$_\n";
        &usage;
    }
}
close IN;
################################################################################
@info=split //,$aas;
@arry=split //,$start;
for($i=0;$i<@info;++$i) {
    $temp=substr $base1,$i,1;
    $temp.=substr $base2,$i,1;
    $temp.=substr $base3,$i,1;
    $encodon{$temp}=$info[$i];
    $code{$temp}=$arry[$i];
}
################################################################################
open IN,$seq_fa or die "read $seq_fa $!\n";
open OT,">$seq_pep" or die "write $seq_pep $!\n";
$/=">";
<IN>;
while(<IN>) {
    chomp;
    @info=split /\n/;
    @arry=split /\+/,$info[0];
    $arry[0].='+';
    unless(defined $arry[1]) {
        @arry=split /\:\-/,$info[0];
        $arry[0].=':-';
    }
    print OT "\>",$arry[0]," ",$arry[1]," ", (split /\//, $codon)[-1],"\n";
    $seq=$info[-1];
    $pep="";
    if($info[0]=~/.*\[Lack 5\'-end\]$/) {
        for($i=0;$i<length($seq);$i+=3) {
            $temp=substr $seq,$i,3;
            unless(defined $encodon{$temp}) {
                $pep.='X';
            }else {
                $pep.=$encodon{$temp};
            }
        }
        $pep=~s/\*$//g;
    }elsif($info[0]=~/.*\[Lack both ends\]$/) {
        for($i=0;$i<length($seq);$i+=3) {
            $temp=substr $seq,$i,3;
            unless(defined $encodon{$temp}) {
                $pep.='X';
            }else {
                $pep.=$encodon{$temp};
            }
        } 
    }elsif($info[0]=~/.*\[Complete\]$/) {
        $temp=substr $seq,0,3;
        if($code{$temp} eq '-') {
            $pep=$encodon{$temp};
        }else {
            $pep=$code{$temp};
        }
        for($i=3;$i<length($seq);$i+=3) {
            $temp=substr $seq,$i,3;
            unless(defined $encodon{$temp}) {
                $pep.='X';
            }else {
                $pep.=$encodon{$temp};
            } 
        }
        $pep=~s/\*$//g;
    }elsif($info[0]=~/.*\[Lack 3'-end\]$/) {
        $temp=substr $seq,0,3;
        if($code{$temp} eq '-') {
            $pep=$encodon{$temp};
        }else {
            $pep=$code{$temp};
        }
        for($i=3;$i<length($seq);$i+=3) {
            $temp=substr $seq,$i,3;
            unless(defined $encodon{$temp}) {
                $pep.='X';
            }else {
                $pep.=$encodon{$temp};
            } 
        }
    }
    if($pep=~/\w+\*\w+/) {
        print STDERR "Error with *\n";
    }
    print OT $pep,"\n";
}
$/="\n";
close OT;
close IN;
################################################################################
sub usage {
    print STDERR
        "\n
        This programme is to transform sequence of fa format to pep\n
        Usage:  perl $0 [codon-table] [input seq.fa] [output seq.pep]\n
        Author by zhouyuanjie\@genomics.org.cn\n
        \n"
}
