/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "whereabouts_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "omic"
  application            = "whereabouts-db"
  is-production          = "false"
  environment-name       = "development"
  db_name                = "whereabouts"
  infrastructure-support = "jamie.draper@digital.justice.gov.uk"
}

resource "kubernetes_secret" "whereabouts_rds" {
  metadata {
    name      = "whereabouts-api-rds-dev"
    namespace = "whereabouts-dev"
  }

  data {
    rds_instance_endpoint = "${module.whereabouts_rds.rds_instance_endpoint}"
    database_name         = "${module.whereabouts_rds.database_name}"
    database_username     = "${module.whereabouts_rds.database_username}"
    database_password     = "${module.whereabouts_rds.database_password}"
    rds_instance_address  = "${module.whereabouts_rds.rds_instance_address}"
  }
}
