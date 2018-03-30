#!/usr/bin/perl -w
use strict;
################################################################################
unless(3 <= @ARGV) {
    &usage;
    exit;
}
################################################################################
my($predict,$contig,$prefix,$min_len,$mark)=@ARGV;
$min_len = $min_len || 0;
$mark = $mark || "GL";
my(@info,$seqid,$i,@temp,$flag,$tmp,%genes,$count,$seq,$len);
################################################################################
open IN,$predict or die "Read $predict $!\n";
$/="Sequence: >";
<IN>;
while(<IN>) {
    chmod;
    @info=split /\n/;
    $info[0]=~/^(\S+)\s*.*/;
    $seqid=$1;
    for($i=7;$i<@info;++$i) {
        $flag=0;
        @temp=split /\s+/,$info[$i];
        next if(@temp < 7);
        if($temp[3]=~/\<(\d+)$/) {
            $flag=1;
            $temp[3]=$1;
            if($temp[4]=~/\>(\d+)$/) {
                $flag=2;
                $temp[4]=$1;
            }
        }elsif($temp[4]=~/\>(\d+)$/) {
            $flag=3;
            $temp[4]=$1;
        }
        $tmp=$temp[3]."\t".$temp[4]."\t".$temp[2]."\t0\t";
        if(0==$flag) {
            $tmp.="Complete";
        }elsif(1==$flag) {
            if($temp[2] eq '+') {
                $tmp.="Lack 5\'-end";
            }else {
                $tmp.="Lack 3\'-end";
            }
        }elsif(2==$flag) {
            $tmp.="Lack both ends";
        }elsif(3==$flag) {
            if($temp[2] eq '+') {
                $tmp.="Lack 3\'-end";
            }else {
                $tmp.="Lack 5\'-end";
            }
        }
        push(@{$genes{$seqid}},$tmp);
    }
}
$/="\n";
close IN;
################################################################################
open IN,$contig or die "Read $contig $!\n";
open GF,">$prefix.gff" or die "Write $prefix $!\n";
print GF "##gff-version 3\n";
open FA,">$prefix.more$min_len.fa" or die "Write $prefix $!\n";
$/=">";
$count=1;
<IN>;
while(<IN>) {
    chomp;
    @info=split /\n/;
    $seqid=shift(@info);
    @temp=split /\s+/,$seqid;
    $seqid=$temp[0];
    $seq=join "",@info;
    $len=length($seq);
    next unless(defined $genes{$seqid});
    print GF "##sequence-region $seqid 1 $len\n";
    for($i=0;$i<@{$genes{$seqid}};++$i) {
        $tmp=&deal_gff($genes{$seqid}[$i],$count,$seqid);
        print GF $tmp;
        my $gene_len;
        ($tmp, $gene_len)=&deal_seq($seq,$genes{$seqid}[$i],$count,$seqid);
        print FA $tmp if ($gene_len >= $min_len);
        ++$count;
    }
}
$/="\n";
close IN;
close GF;
close FA;
################################################################################
sub deal_gff {
    my($infos,$num,$id)=@_;
    my(@arry,$temps);
    @arry=split /\t/,$infos;
    $temps=$id."\tgenemark.m\tgene\t".$arry[0]."\t".$arry[1]."\t\.\t";
    $temps.=$arry[2]."\t\.\t";
    $temps.=sprintf("ID=GL%07d;Name=GL%07d;Note=",
            $num,$num,$num);
    $temps.=$arry[-1]."\n";
    return $temps;
}
################################################################################
sub deal_seq {
    my($line,$infos,$num,$id)=@_;
    my($temps,@arry);
    @arry=split /\t/,$infos;
    $flag = 0;
    $id=sprintf(">%s%07d  [gene]  locus=%s:%d:%d:%s\[",
            $mark,$num,$id,$arry[0],$arry[1],$arry[2]);
    $id.=$arry[-1]."\]\n";
    $temps=substr $line,$arry[0] - 1,$arry[1] - $arry[0] + 1;
    $temps=~tr/atcgn/ATCGN/;
    if($arry[2] eq '-') {
        $temps=reverse $temps;
        $temps=~tr/ATCGatcg/TAGCtagc/;
    }
    $temps=$id.$temps."\n";
    return ($temps, $arry[1] - $arry[0] + 1);
}
################################################################################
    sub usage {
        print STDERR
            "\n
            Description\n
            This stupid script is to deal genemark.meta predict result\n
            Usage:  perl $0 [contig.gmm] [contig.fa] [outfile prefix] [min_length] [sample mark]\n
            Author by zhouyj\n
            \n"
    }
