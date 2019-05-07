terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {}

variable "cluster_state_bucket" {}
