# Introduction

This section introduces scripts for (ii) the visualization of the resulting pangenome networks.

# Requirement

1. "MenuAction.java" is the main script which describes an algorithm for arranging nodes in a network.
2. "pgnVisApp.java" is a public class.
3. "app-manifest" contains information of your jar.
4. "Cytoscape3-api.jar" is a required jar, you can get it from...

# Compiling command

```
javac -cp Cytoscape3-api.jar *.java
jar cfm pgnVisApp.jar app-manifest *.class
```

# Installing the plug-in

Installing the plug-in "pgnVisApp.jar" and visualizing pangenome networks in Cytoscape.

1. Install Java 8  and Cytoscape (version 3.0.0 or above).

2. In the interface in Cytoscape,

   ```
    i. Install the plug-in pgnVisApp.jar through "Apps > App Manager > Install Apps > Install from file…", after which there should be an option named "Arrange nodes" in the "Select" menu.
    ii. Import the edges file of a pangenome network through "File > Import > Network > file".
    iii. Import the nodes file of a pangenome network through "File > Import > Table > file".
    iv. In the "Node Table" in "Table Panel", add two columns named "search" and "coordinate" through "Create New Column > New Single Column > String", which will be used to store the arrangement and coordinate information.
    v. Finally, click the option "Arrange nodes" in the "Select" menu and the pangenome network will be arranged according to rules introduced above.
   ```

After importing files constituting a pangenome network into Cytoscape, users can specify styles of nodes and edges according to certain attributes of them, for convenient observation.
