#!/usr/bin/perl -w
use strict;
use PerlIO::gzip;

die "Usage: $0 <in.clstr> >out.table\n" unless(@ARGV == 1);
my $current_cluster;
open IN,"<:gzip(autopop)", $ARGV[0] or die "$! $ARGV[0]!\n";
while(<IN>) {
	if(/^>/) {
		$current_cluster = (split)[1];
		$current_cluster += 1;
	} 
	else {
		my ($sid, $gid);
		if(/>(\d+)\./){
			($sid, $gid) = />(\d+)\.(\S+?)... /;
		}
		elsif(/_gene_/)
		{
			($gid, $sid) = />((\S+?)_gene_\S+?)... /;
		}
		elsif(/>/)
                {
                        ($sid, $gid) = />(\S+)_(\S+)\.\.\./;
                }
		else{
			($sid, $gid) = />(\S+?)_(\S+?)... /;
		}		
	my ($represent) = /\*$/ ? 1 : 0;
        print "$sid\t$gid\t$current_cluster\t$represent\n";
    }
}
