#!/usr/bin/env bash

# This script determines which environment / cluster should we deploy to
LIST_OF_CHANGED_FILES=`git diff-tree --no-commit-id --name-only -r $(git log --pretty=format:"%h" -1) | grep namespaces | cut -d "/" -f2 | uniq`
LIST_OF_CHANGED_DIR=`git diff-tree --no-commit-id --name-only -r $(git log --pretty=format:"%h" -1) | grep namespaces | cut -d "/" -f3 | uniq`
if [ `echo $LIST_OF_CHANGED_FILES | wc -l` -lt 1 ]; then
  echo "No clusters changes to apply"
else
  for CLUSTER in $LIST_OF_CHANGED_FILES; do
    echo "Running kubectl config use-context $CLUSTER"
    kubectl config use-context $CLUSTER
    echo "Running python3 namespace.py -c $CLUSTER"
    python3 namespace.py -c $CLUSTER
    if [ -z "$(ls -A ./namespaces/$CLUSTER/$DIR/resources)" ]; then
      echo "directory does not exist"
    else
      #terraform init ./namespaces/$CLUSTER/$DIR/resources
      #terraform apply ./namespaces/$CLUSTER/$DIR/resources
      echo "directory exists"
    fi
  done
fi
