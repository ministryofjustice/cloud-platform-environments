/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "cccd_staging_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "laa-get-paid"
  business-unit          = "legal-aid-agency"
  application            = "cccd"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  db_engine_version      = "10.6"
  db_name                = "adp_staging"
}

resource "kubernetes_secret" "cccd_staging_rds" {
  metadata {
    name      = "cccd-staging-rds-output"
    namespace = "cccd-staging"
  }

  data {
    rds_instance_endpoint = "${module.cccd_staging_rds.rds_instance_endpoint}"
    database_name         = "${module.cccd_staging_rds.database_name}"
    database_username     = "${module.cccd_staging_rds.database_username}"
    database_password     = "${module.cccd_staging_rds.database_password}"
    rds_instance_address  = "${module.cccd_staging_rds.rds_instance_address}"
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.cccd_staging_rds.database_username}:${module.cccd_staging_rds.database_password}@${module.cccd_staging_rds.rds_instance_endpoint}/${module.cccd_staging_rds.database_name}"
  }
}
