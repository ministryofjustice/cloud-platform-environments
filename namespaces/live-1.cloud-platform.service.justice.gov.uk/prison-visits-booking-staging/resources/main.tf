terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

variable "cluster_name" {}

variable "cluster_state_bucket" {}
