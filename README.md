# Introduction

This pipeline is used for: (i) construction of pangenome networks and, (ii) visualization of the resulting pangenome networks.

# Requirement

## Make sure the following softwares are installed

(i) the construction of pangenome networks:
Perl (version 5.0 or above),
MetaGeneMark (version 2.8 or above),
BLAT (version 34 or above),
CD-HIT (version 4.5.7 or above),

(ii) the visualization of the resulting pangenome networks:
Cytoscape (version 3.0 or above)
java (version 8 or above)

## Initializion

Make sure you have two inputs:

1. Query assemblies (e.g., "query.assemblies.fasta" in the Demo)
2. A reference genome (e.g., "Escherichia\_coli\_K\_12\_substr\_\_MG1655.genes.fasta" in the Demo)

# Usage

## Construction

```shell
cd Demo
sh flow.sh ./Data/query.assemblies.fasta ./Data/Escherichia_coli_K_12_substr__MG1655.genes.fasta out_prefix > work.sh 
sh work.sh

```

Output files are named "out\_prefix.refined.edge" and "out\_prefix.refined.node" ("out\_prefix.refined.annotated.node" if annotation is performed).

## Visualization

Installing the Cytoscape plugin and visualizing pangenome networks in Cytoscape.

1. Install Java 8  and Cytoscape (version 3.0.0 or above).

2. In the interface in Cytoscape,

   ```
    i. Install the plugin CirSingletonNodesApp.jar through "Apps > App Manager > Install Apps > Install from file…", after which there should be an option named "Arrange node" in the "Select" menu.
    ii. Import the edges file of a pangenome network through "File > Import > Network > file".
    iii. Import the nodes file of a pangenome network through "File > Import > Table > file".
    iv. In the "Node Table" in "Table Panel", add two columns named "search" and "coordinate" through "Create New Column > New Single Column > String", which will be used to store the arrangement and coordinate information.
    v. Finally, click the option "Arrange node" in the "Select" menu and the pangenome network will be arranged according to rules introduced above.
   ```

