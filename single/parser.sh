#!/bin/bash
cd "$(dirname "$0")"
#NODE_IN=$2
#NODE="0"
#NODE=${NODE_IN:-$NODE}
#echo ${NODE}

NSC_IN=$1
NSC="default"
export ptnamespace=${NSC_IN:-$NSC}

export NEO4JDIR="/opt/neo4j"

if [ "$1" == "-h" ] ; then
    echo "Usage: `basename $0` [-h]"
    echo "use log or cluster check"
    echo "example: ./check.sh log"
    echo "example: ./check.sh log {0}"
    echo "example: ./check.sh cluster"
    exit 0
fi 



envsubst < ./template/neo4j.yml > ./deploy/neo4j.yml
envsubst < ./template/dns.yml > ./deploy/dns.yml
envsubst < ./template/configmap.yml > ./deploy/configmap.yml




