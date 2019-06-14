# cloud-platform-environments

[![CircleCI](https://circleci.com/gh/ministryofjustice/cloud-platform-environments.svg?style=svg)](https://circleci.com/gh/ministryofjustice/cloud-platform-environments)

## Intro
This repository is where kubernetes namespaces are managed, across all the clusters. Kubernetes namespaces and resources are defined in the `namespaces` directory in this repository under the corresponding `cluster` name.

### Functionality
The pipeline will for each defined `cluster`:

1) Create a namespace defined the namespace/`cluster` directory. If the namespace already exists on the cluster it will be ignored.
2) Delete any namespaces that exist in the cluster but are not defined in the repository.
3) Create any kubernetes resource that is defined under namespaces/`custer`/`namespace`

### Namespaces
The `namespaces/` directory contains sub directories named after the existing cluster names, and inside, sub directories named after each of the desired namespaces you want to create for each cluster. Placed inside are the kubernetes resource files you want to create in the kubernetes format. Those will be created automatically after a push is made to the Repositories master branch by the AWS code pipeline.

### AWS resources
In a similar fashion as namespaces, you can create AWS resources in your desired namespace. The file structure for that is namespaces/`cluster`/`namespace`/terraform/ and Terraform files should be placed in that route for the pipeline to be triggered and create those AWS resources. Different terraform modules exist, for example: [ECR credentials](https://github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials), [S3 bucket](https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket), and should be used to create these resources as follows:

### Changes within namespaces

Changes within namespaces directory are managed by the `build-environments` concourse job configured [here](https://github.com/ministryofjustice/cloud-platform-concourse/tree/master/pipelines/cloud-platform-live-0/main/build-environments.yaml).
GitHub triggers the build process using [webhook](https://github.com/ministryofjustice/cloud-platform-environments/settings/hooks/32085881). Build itself runs script `whichNamespace.sh` checking for last commit changes, and if it detects any within namespace folder it executes `namespace.py` with appropriate cluster(s) parameter.

#### Example terraform file

```
module "my_S3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=1.0"

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
