#!/bin/bash
cd "$(dirname "$0")"

NSC_IN=$1
NSC="default"
NSC=${NSC_IN:-$NSC}


rm ./deploy/* -rf

