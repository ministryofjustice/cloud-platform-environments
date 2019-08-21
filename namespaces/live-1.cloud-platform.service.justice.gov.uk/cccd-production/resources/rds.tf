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

module "cccd_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  db_engine_version      = "9.6"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
  force_ssl              = "true"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres9.6"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_rds" {
  metadata {
    name      = "cccd-rds"
    namespace = "${var.namespace}"
  }

  data {
    /*
    * NOT NEEDED - APP USES URL ONLY
    *
    * rds_instance_endpoint = "${module.cccd_rds.rds_instance_endpoint}"
    * database_name         = "${module.cccd_rds.database_name}"
    * database_username     = "${module.cccd_rds.database_username}"
    * database_password     = "${module.cccd_rds.database_password}"
    * rds_instance_address  = "${module.cccd_rds.rds_instance_address}"
    */

    url = "postgres://${module.cccd_rds.database_username}:${module.cccd_rds.database_password}@${module.cccd_rds.rds_instance_endpoint}/${module.cccd_rds.database_name}"
  }
}
