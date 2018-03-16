# kubernetes-kickoff

### Buildspec

The `buildspec.yml` file contains the codebuild build specification that will create the resources defined in the `namespaces/` directory.

### Namespaces

The `namespaces/` directory contains sub directorys named after each of the desired namespaces you want to create. Placed inside are the kubernetes resource files you want to create. Those will be created automatically after a push is made to the repos master branch by the aws codepipeline.

### Terraform

The `terraform/` directory contains Terraform resources to create the AWS pipeline for kubernetes namespace and resource creation. To create the pipeline, or make changes:

```
$ cd terraform
$ terraform init
$ terraform apply
```
