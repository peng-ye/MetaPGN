# Introduction

This pipeline is used for: (i) construction of pangenome networks (PGNs) and, (ii) visualization of the resulting pangenome networks.

## I. Steps for constructing pangenome networks
### Requirement

1. Perl (version 5.0 or above, https://www.perl.org/get.html),

2. MetaGeneMark (version 2.8 or above, <http://exon.gatech.edu/license_download.cgi>)

   undefinedFrom decompressedfiles of MetaGeneMark, copy the key “*gm_key[_64/_32]”* to your home directory, and copy the program “*gmhmmp*” and “*MetaGeneMark_v1.mod*” to the directory “Scripts/basic_src” in MetaPGN.

     ```
     cp  gm_key[_64/_32]  ~/.gm_key
     cp  gmhmmp MetaGeneMark_v1.mod path/to/MetaPGN/Scripts/basic_src
     ```

### Usage
#### 1. Make sure you have these two inputs:
1.1 Query assemblies (e.g., "query.assemblies.fasta" in "Demos/Inputs/assemblies/")
1.2 A reference genome (e.g., "Escherichia\_coli\_K\_12\_substr\_\_MG1655.genes.fasta" in "Demos/Reference/Gene_features")

#### 2. Execute the script named “MetaPGN_flow.pl” to generate a shell script (e.g., “MetaPGN.sh”) containing necessary steps in the pipeline (the help text for “MetaPGN_flow.pl” is shown below).
2.1 Usage
```
perl MetaPGN_flow.pl -q <input query assemblies sequence> -qt <input query assemblies type> -ref <input reference sequence> -p <output prefix> <Other options> >MetaPGN.sh
```

2.2 Explanation of options
```
-type   <str>   sequence type of input query assemblies, nt (nucleotide sequence) or aa (amino acid sequence), (default nt)
-q      <str>   input file (in FASTA format) or file list (with the suffix .list) for query sequences
-qt     <str>   source of the input sequence, genome or metagenome (default genome)
-gene   <str>   type of the input sequence, gene or assembly (default assembly)
-ref    <str>   input file (in FASTA format) for the reference sequence
-meta   <str>   input file (in metadata format) for metadata of the reference sequence
-p      <str>   output prefix
-M      <int>   minimum gene length in gene prediction (default 100)
-qs     <str>   qsub or local, when run the Step2. Gene redundancy elimination (default local)
-qsp    <str>   project name for qsub -P (default none)
-qsq    <str>   queue name for qsub -q (default none)
-div    <int>   when you choose -qs qsub, it will divide your gene prediction results into segment (default 10)
-aS     <float> alignment coverage for the shorter sequence (default, nt: 0.9, aa: 0.7)
if set to 0.9, the alignment must cover 90% of the sequence
-i      <float> sequence identity threshold (default, nt: 0.95, aa: 0.7. See Cd-hit manual for more details)
-n      <int>   word_length (default nt: 8, aa: 5. See Cd-hit manual for more details)
-d      <int>   length of description in the *.clstr file (default 0)
if set to 0, it takes the fasta defline and stops at first space (See Cd-hit manual for more details)
-g1     <int>   1 or 0 (default 1)
Based on cd-hit's default algorithm, a sequence is clustered to the first cluster that meet the threshold (fast cluster). If set to 1, the program will cluster it into the most similar cluster that meet the threshold (accurate but slow mode) but either 1 or 0 won't change the representatives of final clusters (See Cd-hit manual for more details)
-T      <int>   number of threads in cd-hit-est, with 0, all CPUs will be used (default 6. See Cd-hit manual for more details)
-G      <int>   use global sequence identity (default 0. See Cd-hit manual for more details)
-c      <int>   cut off for the gene count on an assembly (default 3)
-r      <float> cut off for the ratio of the number of shared genes on an assembly to the total number of genes on that assembly (default 0.5)
-h      <str>   display this help text and exit
```
2.3 Examples
Example 1, the input sequence is nucleotide sequence of assemblies from metagenomes:
```
perl MetaPGN_flow.pl -q Inputs/query.assemblies.list -qt metagenome -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.fasta -meta References/Annotations/Escherichia_coli_K_12_substr__MG1655.idx.metadata -p metagenome_assemblies_nt > MetaPGN.sh
```
Example 2, the input sequence is nucleotide sequence of genes from isolated genomes:
```
perl MetaPGN_flow.pl -q Inputs/genes/query.genes.nt.fasta -qt genome -ref References/Gene_features/Escherichia_coli_K_12_substr__MG1655.genes.fasta -p genome_genes_nt -gene gene > MetaPGN.sh
```
Example 3, the input sequence is amino acid sequence of genes from metagenomes, and the script will use qsub to submit tasks in redundancy elimination of genes onto available computing clusters:
```
perl MetaPGN_flow.pl -q Inputs/query.genes.aa.list -qt metagenome -type aa -ref References/Gene_features/Escherichia_coli_K_12_substr\_\_MG1655.genes.prot.fasta -meta References/Annotations/Escherichia_coli_K_12_substr\_\_MG1655.prot.idx.metadata -gene gene -qs qsub -div 3 -p genome_genes_aa > MetaPGN.sh
```
#### 3. Execute the shell script to construct pangenome networks.
```
Usage: sh MetaPGN.sh [>MetaPGN.log 2> MetaPGN.err &]
```


## II. Steps for installing the plug-in and visualizing pangenome networks in Cytoscape
### Requirement
1. Java (version 8 or above, http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html), 
2. Cytoscape (version 3.0 or above, http://www.cytoscape.org/download.php)
### Usage
#### 1. In the interface in Cytoscape,
​    1.1 Install the plugin *“**pgnVisApp.jar**”* through "Apps > App Manager > Install Apps > Install from file…". These steps are demonstrated as follows:

*Open “App Manager”*

![](./Figures/installation0.png)

*Install “pgnVisApp.jar”*

![](./Figures/installation1.png)

*The “pgnVisApp” appears at the “Currently Installed” panel*

![](./Figures/installation2.png)

​    1.2 After installing, there should be an optionnamed "Arrange node" in the "Select" menu. 

*An option named “PGN Arrange nodes” in the “Select”menu after installing*

![](./Figures/installation3.png)

#### 2. Import the network files into Cytoscape

​    2.1 Get files of apangenome network  (used below are filesfor the pangenome network of the 5 *E.coli* strains. You can get it from "Network_files/Text_files/5_Ecoli_strains").

​    2.2 Import the edge fileof the pangenome network through "File > Import > Network >file".

*Importthe edge file*

![](./Figures/import_edge1.png)

*Click “OK”*

![](./Figures/import_edge2.png)

​    2.3 Import the node fileof the pangenome network through "File > Import > Table >file". 

*Import the node file (the interface shows the pangenome network before arrangement)*

![](./Figures/import_node1.png)

*Click “OK”*

![](./Figures/import_node2.png)

#### 3. Arrange nodes

​    3.1 In the "NodeTable" in "Table Panel", add two columns named"search" and "coordinate" through "Create New Column> New Single Column > String", which will be used to store thearrangement and coordinate information.

*Addtwo string-type columns named “search” and “coordinate”*

![](./Figures/add_attribute1.png)

*Column “search” and “coordinate” appear at the “Node Table” panel*

![](./Figures/add_attribute2.png)

​    3.2 Click the option "PGN Arrange nodes" in the "Select" menu and the pangenome
network will be arranged according to rules introduced in the paper.

*Click “PGN Arrange nodes”*

![](./Figures/arrange1.png)

*The pangenome network after arrangement (Most of the nodes have been arranged, while others remain in the central area)*

![](./Figures/arrange2.png)

#### 4. [Optional] Customize the shape of nodes and edges, searchtargeted nodes, and retrieve annotations of selected elements.

​    4.1 In the “Style” panelof the “Control Panel” (red rectangle), customize the shape of nodes and edges basedon their attributes of interest. The example below selects the “Ripple” stylefor the network (purple rectangle), customizes the fill color for nodes accordingto their status (green for “reference-specific”, orange for “query-specific”and blue for “shared” nodes) (dark blue rectangle), and specifies the size ofnodes to reflect their weights in the network (green rectangle). Moreattributes can be customized and are not shown here (orange rectangle).

![](./Figures/optional_opt1.png)

Select a node of interest from the “Table Panel” (dark blue dashed
rectangle) or the original node file according to its annotation, type the ID
(shared name) in the search box (red dashed rectangle) and press enter to
locate the node (Shown below is Node 1237, which represents the sequence of
gene *fliD*).

*Type the ID of the targeted node and press enter to locate the node*

![](./Figures/optional_opt2.png)

*Click “Zoom selected region” to show the node*

![](./Figures/optional_opt3.png)

*Click “Zoom Out” or scroll down the mouse wheel to show its context*

![](./Figures/optional_opt4.png)

*The context of the selected node is shown after properly zooming*

![](./Figures/optional_opt5.png)

​    4.3 Select nodes (or edges) of interest to retrieve their annotation

*Select a node within an interesting loop, and click “First Neighbors of Selected Nodes” (for 4 times in this example), or press and hold “Ctrl” until done selecting nodes using the mouse*

![](./Figures/optional_opt6.png)

*Annotation of selected nodes in the “Table Panel” (dark blue dashed rectangle)*

![](./Figures/optional_opt7.png)
