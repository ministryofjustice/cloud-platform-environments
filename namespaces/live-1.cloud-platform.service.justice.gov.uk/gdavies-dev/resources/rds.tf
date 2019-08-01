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
module "gdavies_dev_team_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "gdavies-dev-repo"
  business-unit          = "gdavies-dev-bu"
  application            = "gdaviesdevapp"
  is-production          = "false"
  db_engine_version      = "10"
  environment-name       = "development"
  infrastructure-support = "gareth.davies@digtal.justice.gov.uk"
  force_ssl              = "true"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres10"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "gdavies_dev_team_rds" {
  metadata {
    name      = "gdavies-dev-team-rds-instance-output"
    namespace = "gdavies-dev"
  }

  data {
    rds_instance_endpoint = "${module.gdavies_dev_team_rds.rds_instance_endpoint}"
    database_name         = "${module.gdavies_dev_team_rds.database_name}"
    database_username     = "${module.gdavies_dev_team_rds.database_username}"
    database_password     = "${module.gdavies_dev_team_rds.database_password}"
    rds_instance_address  = "${module.gdavies_dev_team_rds.rds_instance_address}"
    url                   = "postgres://${module.gdavies_dev_team_rds.database_username}:${module.gdavies_dev_team_rds.database_password}@${module.gdavies_dev_team_rds.rds_instance_endpoint}/${module.gdavies_dev_team_rds.database_name}"
  }
}
