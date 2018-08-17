perl MetaPGN_flow.pl -q Inputs/genes/query.genes.nt.fasta -qt genome -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.fasta -p genome_genes_nt -gene gene > MetaPGN.sh
sh MetaPGN.sh > MetaPGN.log 2> MetaPGN.err
