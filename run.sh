#!/bin/bash
cd "$(dirname "$0")"

NSC_IN=$1
NSC="default"
NSC=${NSC_IN:-$NSC}
./parser.sh ${NSC}

kubectl apply -f ./ -n ${NSC}

