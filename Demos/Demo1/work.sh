perl MetaPGN_flow.pl -q Inputs/query.assemblies.list -qt metagenome -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.fasta -meta References/Annotations/Escherichia_coli_K_12_substr__MG1655.idx.metadata -p metagenome_assemblies_nt > MetaPGN.sh
sh MetaPGN.sh > MetaPGN.log 2> MetaPGN.err
