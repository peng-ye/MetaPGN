perl MetaPGN_flow.pl -q Inputs/query.genes.aa.list -qt metagenome -type aa -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.prot.fasta -meta References/Annotations/Escherichia_coli_K_12_substr__MG1655.prot.idx.metadata -gene gene -qs qsub -div 3 -p genome_genes_aa -qsq st.q -qsp F16ZQSB1SY2921 > MetaPGN.sh
sh MetaPGN.sh > MetaPGN.log 2>MetaPGN.err
