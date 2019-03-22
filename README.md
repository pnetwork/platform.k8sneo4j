# platform.k8sneo4j

## environment
 * need to set up node label
 * need to at least 3 nodes shown in setlabel.sh
 * node label: ptnodetype=datanode

## exeute

```
./setlabel 
./parser.sh {namespace} : it will parse the file to from Jenkins
./run.sh {namespace} : it will launch all stuff in deploy directory for deployment
```

## check result

```
./check log : make sure the 0 node's status (defualt)
./check log 0 : make sure the given node's status
./check.sh cluster: make sure the cluster status
```

## how to parse namespace 

For suitable on different namespace deployment of the Neo4j
we need an template to define keep the namespace variable in said neo4j.yml.j2. 
use 

```
./parse.sh namespace 
```

to create the template for different namespace



