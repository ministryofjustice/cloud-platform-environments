# cloud-platform-environments

## Intro
This repository contains the necessary files to create a pipeline in AWS to create and delete kubernetes cluster namespaces and resources after a push is made to the master branch. The AWS resources and pipeline can be created with the terraform templates included. One Pipeline exist for each cluster under the `terraform` directory. Kubernetes namespaces and resources are defined in the `namespaces` directory in this repository under the corresponding `cluster` name.

### Functionality
The pipeline will for each defined `cluster`:

1) Create a namespace defined the namespace/`cluster` directory. If the namespace already exists on the cluster it will be ignored.
2) Delete any namespaces that exist in the cluster but are not defined in the repository.
3) Create any kubernetes resource that is defined under namespaces/`custer`/`namespace`

### namespace.py
namespace.py is the main python script in charge of creating, deleting namespaces and creating resources. It is triggered by the pipeline and takes as an argument the cluster name.

usage:

```
python3 namespace.py
usage: namespace.py [-h] -c CLUSTER
namespace.py: error: the following arguments are required: -c/--cluster
```

### Namespaces
The `namespaces/` directory contains sub directories named after the existing cluster names, and inside, sub directories named after each of the desired namespaces you want to create for each cluster. Placed inside are the kubernetes resource files you want to create in the kubernetes format. Those will be created automatically after a push is made to the Repositories master branch by the saws code pipeline.

### AWS resources
In a similar fashion as namespaces, you can create AWS resources in your desired namespace. The file structure for that is namespaces/`cluster`/`namespace`/terraform/ and Terraform files should be placed in that route for the pipeline to be triggered and create those AWS resources. Different terraform modules exist, for example t,[ECR credentials](https://github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials), [S3 bucket](https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket), and should be used to create these resources as follows:

#### Example terraform file

```
module "my_S3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=master"

  team_name = "my-team"
  bucket_id = "my-bucket"
}

resource "kubernetes_secret" "my_S3_bucket_creeds" {
  metadata {
    name = "my-S3-bucket-creeds"
  }

  data {
    access_key_id     = "${module.my_s3_bucket.access_key_id}"
    Secret_access_key = "${module.my_s3_bucket.secret_access_key}"
    Bucket_name       = "${module.my_s3_bucket.bucket_name}"
  }
}
```

### Terraform
The terraform/ directory contains Terraform resources to create the AWS pipeline for kubernetes namespace and resource creation under the corresponding cluster name. To create the pipeline, or make changes:

```
$ cd terraform/<cluster>
$ terraform init
$ terraform apply
```

The configuration changes, like repository, branch or project name can be done from the terraform/<cluster>/terraform.tfvars file

### Buildspec
The buildspec.yml file lives under terraform/`cluster` and contains the codebuild build specification that will create the resources defined in the namespaces/`cluster` directory. These will be the commands executed by the pipeline every time it runs.

### Kube config file
You must place the cluster's kubecfg.yaml file in the S3 bucket keystore S3://`cluster-keystore`/kubecfg.yaml. That is the way the code pipeline connects to the cluster to perform operations.

### Build alarms: Success/failure slackbot
The build-alarms/ directory contains all you need to setup a slackbot to notify users on the success/failure of their namespace creation.

This creates a Cloudwatch rule to monitor everything Codebuild writes to Cloudwatch. When this rule is matched a Lambda is triggered, sending an alert to a specified slack channel.
