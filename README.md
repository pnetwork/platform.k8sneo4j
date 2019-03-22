# platform.k8sneo4j
1. 
For suitable on different namespace deployment of the Neo4j
we need an template to define keep the namespace variable in said neo4j.yml.j2. 
use ./parse.sh namespace 
to create the template for different namespace


2. check result
./check log : make sure the 0 node's status (defualt)
./check log 0 : make sure the given node's status
./check.sh cluster: make sure the cluster status

