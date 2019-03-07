terraform {
  backend "s3" {}
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
module "example_team_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "cica"
  business-unit          = "criminal-injury-compensation"
  application            = "notify-gateway"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "infrastructure@cica.gsi.gov.uk"
}

resource "kubernetes_secret" "example_team_rds" {
  metadata {
    name      = "example-team-rds-instance-output"
    namespace = "cica-development"
  }

  data {
    rds_instance_endpoint = "${module.example_team_rds.rds_instance_endpoint}"
    database_name         = "${module.example_team_rds.database_name}"
    database_username     = "${module.example_team_rds.database_username}"
    database_password     = "${module.example_team_rds.database_password}"
    rds_instance_address  = "${module.example_team_rds.rds_instance_address}"
  }
}
