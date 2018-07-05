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
    for file in namespaces/*; do
      cluster="$(basename ${file})"
      echo $cluster
      for product in namespaces/$cluster/*; do
        if [ -d "${product}" ]; then
          echo "Applying terraform resources on $(basename ${product})"
          service=$(basename ${product})
          terraform init namespaces/$cluster/$service/resources
          terraform apply namespaces/$cluster/$service/resources
        fi
      done
    done
  done
fi
