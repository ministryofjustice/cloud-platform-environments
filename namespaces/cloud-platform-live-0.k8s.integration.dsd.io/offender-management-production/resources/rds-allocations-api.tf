terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {}

variable "cluster_state_bucket" {}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "allocation-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.0"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "offender-management"
  business-unit          = "HMPPS"
  application            = "offender-management-allocation-api"
  is-production          = "true"
  environment-name       = "production"
  infrastructure-support = "omic@digtal.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10.5"
  db_name                = "allocations"
}

resource "kubernetes_secret" "allocation-rds" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = "offender-management-production"
  }

  data {
    rds_instance_endpoint = "${module.allocation-rds.rds_instance_endpoint}"
    database_name         = "${module.allocation-rds.database_name}"
    database_username     = "${module.allocation-rds.database_username}"
    database_password     = "${module.allocation-rds.database_password}"
    rds_instance_address  = "${module.allocation-rds.rds_instance_address}"
  }
}
