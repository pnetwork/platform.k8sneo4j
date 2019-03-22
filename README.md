# platform.k8sneo4j

##0. environment
 * need to set up node label
 * need to at least 3 nodes shown in setlabel.sh
 * node label: ptnodetype=datanode

##1. exeute
 ./run.sh {namespace}

##2. parse namespace 
For suitable on different namespace deployment of the Neo4j
we need an template to define keep the namespace variable in said neo4j.yml.j2. 
use ./parse.sh namespace 
to create the template for different namespace


##3. check result
./check log : make sure the 0 node's status (defualt)
./check log 0 : make sure the given node's status
./check.sh cluster: make sure the cluster status

