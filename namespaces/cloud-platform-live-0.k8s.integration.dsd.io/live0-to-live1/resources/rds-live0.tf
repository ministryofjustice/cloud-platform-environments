/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "live0_migration_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business_unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
}

resource "kubernetes_secret" "live0_migration_rds" {
  metadata {
    name      = "live0_migration_rds-instance-output"
    namespace = "live0-to-live1"
  }

  data {
    rds_instance_endpoint = "${module.live0_migration_rds.rds_instance_endpoint}"
    rds_instance_address  = "${module.live0_migration_rds.rds_instance_address}"
    database_name         = "${module.live0_migration_rds.database_name}"
    database_username     = "${module.live0_migration_rds.database_username}"
    database_password     = "${module.live0_migration_rds.database_password}"
  }
}
