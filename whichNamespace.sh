#!/usr/bin/env bash

# This script determines which environment / cluster should we deploy to
LIST_OF_CHANGED_FILES=`git diff-tree --no-commit-id --name-only -r $(git log --pretty=format:"%h" -1) | grep namespaces | cut -d "/" -f2 | uniq`
# LIST_OF_CHANGED_FILES=`git diff-tree --no-commit-id --name-only -r afed721 | grep namespaces | cut -d "/" -f2 | uniq`
if [ `echo $LIST_OF_CHANGED_FILES | wc -l` -lt 1 ]; then
  echo "No clusters changes to apply"
else
  for CLUSTER in $LIST_OF_CHANGED_FILES; do
    if [[ "$CLUSTER" =~ non-production\.k8s.* ]]; then
      KEYSTORE='non-production-cluster-keystore'
    elif [[ "$CLUSTER" =~ cloud-platforms-test\.k8s.* ]]; then
      KEYSTORE="cloud-platform-test-cluster-keystore"
    fi
    echo "Running aws s3 cp s3://$KEYSTORE/kubecfg.yaml ~/.kube/config"
    aws s3 cp s3://$KEYSTORE/kubecfg.yaml ~/.kube/config
    echo "Running kubectl config use-context $CLUSTER"
    kubectl config use-context $CLUSTER
    echo "Running python3 namespace.py -c $CLUSTER"
    python3 namespace.py -c $CLUSTER
  done
fi
