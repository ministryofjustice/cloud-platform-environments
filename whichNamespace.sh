#!/usr/bin/env bash

# This script determines which environment / cluster should we deploy to
LIST_OF_CHANGED_FILES=`git diff-tree --no-commit-id --name-only -r $(git log --pretty=format:"%h" -1) | grep namespaces | cut -d "/" -f2 | uniq`
if [ `echo $LIST_OF_CHANGED_FILES | wc -l` -lt 1 ]; then
  echo "No clusters changes to apply"
else
  for CLUSTER in $LIST_OF_CHANGED_FILES; do
    echo "Running kubectl config use-context $CLUSTER"
    kubectl config use-context $CLUSTER
    echo "Running python3 namespace.py -c $CLUSTER"
    python3 namespace.py -c $CLUSTER
  done
fi
