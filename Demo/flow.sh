#!bin/bash
if [ ! $3 ]; then
echo "This flow is used to construction of pangenome networks."
echo "sh $0 <input Gene-marked.scaftigs> <input reference sequence> <output prefix> >work.sh"
echo "e.g.:"
echo "sh flow.sh ./Data/query.assemblies.fasta ./Data/Escherichia_coli_K_12_substr__MG1655.genes.fasta out.prefix >work.sh"

exit
fi

echo "# Gene prediction (You should copy ../Scripts/.gm_key to /home/your_dir/ first)"
echo "../Scripts/MetaGeneMark_v2.8.pl -i $1 -o $3.predict -s $3.predict -M 100 2>gene_prediction.log"

echo -e "\n# Redundancy elimination"
echo "../Scripts/cd-hit-div -i $3.predict.more100.fa -o $3.sort.fasta -div 1 >cd-hit-div.log"
echo "cat $3.sort.fasta-* > $3.sort.fasta; rm $3.sort.fasta-*"
echo "../Scripts/cd-hit-est -i $3.sort.fasta -o $3.90_95.fasta -n 8 -d 0 -g 1 -T 6 -G 0 -aS 0.9 -c 0.95 >cd-hit-est.log"
echo "perl ../Scripts/cdhit_clstr2tbl.pl $3.90_95.fasta.clstr > $3.nrgc 2>$3.nrgc.log"
echo "perl ../Scripts/cds2ssgc.pl $3.90_95.fasta $3.nrgc >$3.ssgc 2>cds2ssgc.err.log"

echo -e "\n# Identification of gene status (shared, query-specific, or reference-specific)"
echo "../Scripts/blat -noHead -noTrimA $2 $3.90_95.fasta $3.ref_cds.blat >blat.log"
echo "awk '{print \$3,\$1\"_\"\$2}' $3.nrgc >genes.name.num.list"
echo "perl ../Scripts/blat.filter.pl -c 3 -r 0.5 genes.name.num.list  $3.ref_cds.blat $3.ssgc >$3.ref_cds.blat_c3r0.5_f"
echo "perl ../Scripts/mapping.pl -s K12 $2 $3.nrgc $3.ref_cds.blat_c3r0.5_f >K12.nrgc"
echo "perl ../Scripts/cds2ssgc.ref.v3.pl $2 K12.nrgc K12 >K12.ssgc 2>K12.ssgc.err.log"

echo -e "\n# Identification of adjacency status (share, query-specific, or reference-specific) and generation of the pangenome network"
echo "../Scripts/grapher.pl -c 3 -r 0.5 -p $3 $3.ssgc K12.ssgc"

echo -e "\n# Refinement of the pangnome network"
echo "perl ../Scripts/refined.pl -p $3.refined $3 2>$3.refinement.log"

echo -e "\n# Optional annotation step"
echo "perl ../Scripts/add.annotation.K12.pl -p $3.refined.annotated $3.refined 2>$3.annotation.log"
