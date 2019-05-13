/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "cccd_dev_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.0"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "laa-get-paid"
  business-unit          = "legal-aid-agency"
  application            = "cccd"
  is-production          = "false"
  environment-name       = "dev"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  db_engine_version      = "10.6"
}

resource "kubernetes_secret" "cccd_dev_rds" {
  metadata {
    name      = "cccd-dev-rds-output"
    namespace = "cccd-dev"
  }

  data {
    rds_instance_endpoint = "${module.cccd_dev_rds.rds_instance_endpoint}"
    database_name         = "${module.cccd_dev_rds.database_name}"
    database_username     = "${module.cccd_dev_rds.database_username}"
    database_password     = "${module.cccd_dev_rds.database_password}"
    rds_instance_address  = "${module.cccd_dev_rds.rds_instance_address}"
    url                   = "postgres://${module.cccd_dev_rds.database_username}:${module.cccd_dev_rds.database_password}@${module.cccd_dev_rds.rds_instance_endpoint}/${module.cccd_dev_rds.database_name}"
  }
}
