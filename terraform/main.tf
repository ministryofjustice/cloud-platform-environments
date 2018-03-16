terraform {
  backend "s3" {
    bucket = "moj-cp-k8s-kickoff-terraform"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 1.9.0"
  region = "eu-west-1"
}

#locals {
#  k8s_domain_name = "${var.k8s_domain_prefix}.${var.base_domain_name}"
#  sandbox_domain_name = "${var.sandbox_domain_prefix}.${local.k8s_domain_name}"
#}
