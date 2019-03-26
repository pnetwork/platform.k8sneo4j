#!/bin/bash
cd "$(dirname "$0")"

NSC_IN=$1
NSC="default"
NSC=${NSC_IN:-$NSC}


kubectl delete -f deploy/

ssh root@172.16.155.207 rm /opt/neo4j/* -rf
ssh root@172.16.155.208 rm /opt/neo4j/* -rf
ssh root@172.16.155.209 rm /opt/neo4j/* -rf
ssh root@172.16.155.210 rm /opt/neo4j/* -rf

rm ./deploy/* -rf

