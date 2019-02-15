/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "categorisation_tool_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "omic"
  application            = "categorisation-tool-db"
  is-production          = "false"
  environment-name       = "development"
  db_name                = "categorisation_tool"
  infrastructure-support = "steve.rendell@digital.justice.gov.uk"
}

resource "kubernetes_secret" "categorisation_tool_rds" {
  metadata {
    name      = "categorisation-tool-rds-dev"
    namespace = "categorisation-tool-dev"
  }

  data {
    rds_instance_endpoint = "${module.categorisation_tool_rds.rds_instance_endpoint}"
    database_name         = "${module.categorisation_tool_rds.database_name}"
    database_username     = "${module.categorisation_tool_rds.database_username}"
    database_password     = "${module.categorisation_tool_rds.database_password}"
    rds_instance_address  = "${module.categorisation_tool_rds.rds_instance_address}"
  }
}
