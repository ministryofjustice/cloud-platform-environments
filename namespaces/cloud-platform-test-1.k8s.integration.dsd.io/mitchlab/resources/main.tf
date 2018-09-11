terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=dynamic-subnets"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "mitchlab"
  ec_engine              = "redis"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  node_type              = "cache.m3.medium"
  number_of_nodes        = 1
  port                   = 6379
  business-unit          = "mitchlab"
  application            = "mitchlab"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "dimitrios.karagiannis@digtal.justice.gov.uk"
}

resource "kubernetes_secret" "elasticache" {
  metadata {
    name      = "elasticache"
    namespace = "mitchlab"
  }

  data {
    nodes = "${jsonencode(module.example_team_ec_cluster.cache_nodes)}"
  }
}
