terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "laa-great-ideas"
  repo_name = "laa-great-ideas"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-laa-great-ideas"
    namespace = "laa-great-ideas-uat"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}

variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "laa-great-ideas-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "laa-great-ideas"
  business-unit          = "laa"
  application            = "laa-great-ideas"
  is-production          = "false"
  environment-name       = "uat"
  infrastructure-support = "laa-great-ideas@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10.6"
  db_name                = "laa_great_ideas_db"
}

resource "kubernetes_secret" "laa-great-ideas-rds" {
  metadata {
    name      = "laa-great-ideas-rds-instance-output"
    namespace = "laa-great-ideas-uat"
  }

  data {
    rds_instance_endpoint = "${module.laa-great-ideas-rds.rds_instance_endpoint}"
    database_name         = "${module.laa-great-ideas-rds.database_name}"
    database_username     = "${module.laa-great-ideas-rds.database_username}"
    database_password     = "${module.laa-great-ideas-rds.database_password}"
    rds_instance_address  = "${module.laa-great-ideas-rds.rds_instance_address}"
  }
}
