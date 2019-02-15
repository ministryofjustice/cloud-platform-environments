terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
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
  environment-name       = "staging"
  infrastructure-support = "laa-great-ideas@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10.5"
  db_name                = "laa_great_ideas_db"
}

resource "kubernetes_secret" "laa-great-ideas-rds" {
  metadata {
    name      = "laa-great-ideas-rds-instance-output"
    namespace = "laa-great-ideas-staging"
  }

  data {
    rds_instance_endpoint = "${module.laa-great-ideas-rds.rds_instance_endpoint}"
    database_name         = "${module.laa-great-ideas-rds.database_name}"
    database_username     = "${module.laa-great-ideas-rds.database_username}"
    database_password     = "${module.laa-great-ideas-rds.database_password}"
    rds_instance_address  = "${module.laa-great-ideas-rds.rds_instance_address}"
  }
}
