/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "cccd_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.3"

  cluster_name                = "${var.cluster_name}"
  cluster_state_bucket        = "${var.cluster_state_bucket}"
  team_name                   = "laa-get-paid"
  business-unit               = "legal-aid-agency"
  application                 = "cccd"
  is-production               = "false"
  environment-name            = "api-sandbox"
  infrastructure-support      = "crowncourtdefence@digtal.justice.gov.uk"
  db_engine_version           = "9.6"
  allow_major_version_upgrade = "true"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_rds" {
  metadata {
    name      = "cccd-rds"
    namespace = "cccd-api-sandbox"
  }

  data {
    rds_instance_endpoint = "${module.cccd_rds.rds_instance_endpoint}"
    database_name         = "${module.cccd_rds.database_name}"
    database_username     = "${module.cccd_rds.database_username}"
    database_password     = "${module.cccd_rds.database_password}"
    rds_instance_address  = "${module.cccd_rds.rds_instance_address}"
    url                   = "postgres://${module.cccd_rds.database_username}:${module.cccd_rds.database_password}@${module.cccd_rds.rds_instance_endpoint}/${module.cccd_rds.database_name}"
  }
}
