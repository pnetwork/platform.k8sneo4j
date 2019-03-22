#!/bin/bash

NODE_IN=$2
NODE="0"
NODE=${NODE_IN:-$NODE}
echo ${NODE}

if [ "$1" == "-h" ] ; then
    echo "Usage: `basename $0` [-h]"
    echo "use log or cluster check"
    echo "example: ./check.sh log"
    echo "example: ./check.sh log {0}"
    echo "example: ./check.sh cluster"
    exit 0
fi 

# make sure the result
#2019-03-22 02:03:25.349+0000 INFO  Mounted REST API at: /db/manage
#2019-03-22 02:03:27.389+0000 INFO  Remote interface available at http://neo4j-core-2.neo4j.jj.svc.cluster.local:7474/
#where jj is in your namespace, one can access throuth http://neo4j-core-2.neo4j.jj.svc.cluster.local:7474/
if [ $1 = "log" ]; then
kubectl logs neo4j-core-${NODE}
fi

if [ $1 = "cluster" ]; then
kubectl exec neo4j-core-${NODE} -- bin/cypher-shell --format verbose "CALL dbms.cluster.overview()"
fi



