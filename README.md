# cloud-platform-environments

## Intro

This repo contains the necesary files to create a pipeline in aws to create and delete kubernetes cluster namespaces and resources after a push is made to the master branch.
The aws resources and pipeline can be created with the terraform templates included. One Pipeline exist for each cluster under the `terraform` directory.
Kubernetes namespaces and resources are defined in the namespaces directory in this repo under the corresponding cluster name.

### Functionality

The pipeline will for each defined cluster:
1) create any namespace defined in the `namespaces/<cluster>` directory in the corresponding cluster that does not actually exist on the cluster.
2) delete any namespaces that exist in the <cluster> but is not defined in the repo.
3) create any kubernetes resource that is defined under `namespaces/<cluster>`

### namespace.py

namespace.py is the main python script in charge of creating, deleting namespaces and creating resources. It is triggered by the pipeline and takes as an argument the cluster name.
usage:
```
python3 namespace.py
usage: namespace.py [-h] -c CLUSTER
namespace.py: error: the following arguments are required: -c/--cluster
```

### Namespaces

The `namespaces/` directory contains the cluster names, and inside sub directories named after each of the desired namespaces you want to create. Placed inside are the kubernetes resource files you want to create in the kubernetes format. Those will be created automatically after a push is made to the repos master branch by the aws codepipeline.

### Changes within namespaces

Changes within namespaces directory are managed by concourse job configured with `fly` and running on live-0 cluster.
Command used to create build job is `fly --target live0 sp -c pipeline.yaml -p build-environments`.
GitHub triggers the build process using [webhook](https://github.com/ministryofjustice/cloud-platform-environments/settings/hooks/32085881). Build itself runs script `whichNamespace.sh` checking for last commit changes, and if it detects any within namespace folder it executes `namespace.py` with appropriate cluster(s) parameter.

### Terraform

The `terraform/` directory contains Terraform resources to create the AWS pipeline for kubernetes namespace and resource creation under the corresponding cluster name. To create the pipeline, or make changes:

```
$ cd terraform/<cluster>
$ terraform init
$ terraform apply
```
The configuration changes, like repo, branch or project name can be done from the `terraform/<cluster>/terraform.tfvars` file

### Buildspec

The `buildspec.yml` file lives under `terraform/<cluster>` and contains the codebuild build specification that will create the resources defined in the `namespaces/<cluster>` directory. These will be the commands executed by the pipeline every time it runs.

### Kube config kubecfg.yaml file

You must place the cluster's kubecfg.yaml file in the s3 bucket keystore `s3://<cluster-keystore>/kubecfg.yaml`. That is the way the codepipeline connects to the cluster to perform operations.

### Build alarms: Success/failure slackbot

The `build-alarms/` directory contains all you need to setup a slackbot to notify users on the success/failure of their namespace creation.

This creates a Cloudwatch rule to monitor everything Codebuild writes to Cloudwatch. When this rule is matched a Lambda is triggered, sending an alert to a specified slack channel.
