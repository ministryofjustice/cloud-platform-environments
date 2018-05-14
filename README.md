# k8s-nonprod-environments

### Intro
This repo contains the necesary files to create a pipeline in aws to create kubernetes cluster namespaces and resources after a push is made to the master branch of a given repo.
The aws resources and pipeline can be created with the terraform templates included.
Kubernetes namespaces and resources are defined in the namespaces directory in this repo.


### Buildspec

The `buildspec.yml` file contains the codebuild build specification that will create the resources defined in the `namespaces/` directory. These will be the commands executed by the pipeline every time it runs.

### Namespaces

The `namespaces/` directory contains sub directorys named after each of the desired namespaces you want to create. Placed inside are the kubernetes resource files you want to create in the kubernetes format. Those will be created automatically after a push is made to the repos master branch by the aws codepipeline.

### Terraform

The `terraform/` directory contains Terraform resources to create the AWS pipeline for kubernetes namespace and resource creation. To create the pipeline, or make changes:

```
$ cd terraform
$ terraform init
$ terraform apply
```
The configuration changes, like repo, branch or project name can be done from the `terraform/variables.tf` file

### Kube config kubecfg.yaml file

You must place the cluster's kubecfg.yaml file in the s3 bucket keystore `s3://non-production-cluster-keystore/kubecfg.yaml`. That is the way the codepipeline connects to the cluster to perform operations.

### Build alarms: Success/failure slackbot

The `build-alarms/` directory contains all you need to setup a slackbot to notify users on the success/failure of their namespace creation. 

This creates a Cloudwatch rule to monitor everything Codebuild writes to Cloudwatch. When this rule is matched a Lambda is triggered, sending an alert to a specified slack channel.  