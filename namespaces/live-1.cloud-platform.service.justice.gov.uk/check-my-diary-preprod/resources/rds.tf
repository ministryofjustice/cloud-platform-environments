/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "checkmydiary_dev_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "check-my-diary"
  application            = "check-my-diary"
  is-production          = "false"
  environment-name       = "dev"
  db_name                = ""
  infrastructure-support = "checkmydiary@digital.justice.gov.uk"
}

resource "kubernetes_secret" "checkmydiary_dev_rds" {
  metadata {
    name      = "check-my-diary-rds-dev"
    namespace = "check-my-diary-dev"
  }

  data {
    rds_instance_endpoint = "${module.checkmydiary_dev_rds.rds_instance_endpoint}"
    database_name         = "${module.checkmydiary_dev_rds.database_name}"
    database_username     = "${module.checkmydiary_dev_rds.database_username}"
    database_password     = "${module.checkmydiary_dev_rds.database_password}"
    rds_instance_address  = "${module.checkmydiary_dev_rds.rds_instance_address}"
  }
}
