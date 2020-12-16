/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_crime_apps_team_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket
  team_name            = "laa-crime-apps-team"
  business-unit        = "Crime Apps"
  application          = "laa-court-data-adaptor"
  is-production        = "false"
  namespace            = var.namespace

  # change the postgres version as you see fit.
  db_engine_version      = "11"
  environment-name       = "staging"
  infrastructure-support = "laa@digital.justice.gov.uk"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres11"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".


  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_crime_apps_team_rds" {
  metadata {
    name      = "laa-court-data-adaptor-instance-output"
    namespace = "laa-court-data-adaptor-stage"
  }

  data = {
    url = "postgres://${module.laa_crime_apps_team_rds.database_username}:${module.laa_crime_apps_team_rds.database_password}@${module.laa_crime_apps_team_rds.rds_instance_endpoint}/${module.laa_crime_apps_team_rds.database_name}"
  }
}

