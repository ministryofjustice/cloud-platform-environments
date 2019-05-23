#!/bin/bash
set -xe

export ECR="754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/tools"
wget -qO- https://github.com/hiddeco/cronjobber/archive/0.2.0.tar.gz | tar xz -
pushd cronjobber-0.2.0
docker build -t "${ECR}:cronjobber" .
docker push "${ECR}:cronjobber"
cp deploy/crd.yaml ../cronjobber-crd.yaml
cp deploy/deploy.yaml ../cronjobber-deploy.yaml
cp deploy/rbac.yaml ../cronjobber-rbac.yaml
popd
gsed -i 's/^metadata:/metadata:\n  namespace: cronjobber/g' cronjobber-crd.yaml
gsed -i 's/^metadata:/metadata:\n  namespace: cronjobber/g' cronjobber-deploy.yaml
gsed -i 's/^metadata:/metadata:\n  namespace: cronjobber/g' cronjobber-rbac.yaml
gsed -i 's/namespace: default/namespace: cronjobber/' cronjobber-rbac.yaml
gsed -i "s#image: quay.io/hiddeco/cronjobber:0.2.0#image: ${ECR}:cronjobber#" cronjobber-deploy.yaml
rm -fr cronjobber-0.2.0
