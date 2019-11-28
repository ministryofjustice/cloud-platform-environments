/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.0"
  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket
  team_name            = "example-repo"
  business-unit        = "example-bu"
  application          = "cptf11app"
  is-production        = "false"

  # change the postgres version as you see fit.
  db_engine_version      = "10"
  environment-name       = "development"
  infrastructure-support = "example-team@digital.justice.gov.uk"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres10"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate). 
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  apply_method = "pending-reboot"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_rds" {
  metadata {
    name      = "cp-team-rds-instance-output"
    namespace = "cp-terraform-module-testing"
  }

  data = {
    rds_instance_endpoint = module.example_team_rds.rds_instance_endpoint
    database_name         = module.example_team_rds.database_name
    database_username     = module.example_team_rds.database_username
    database_password     = module.example_team_rds.database_password
    rds_instance_address  = module.example_team_rds.rds_instance_address
    access_key_id         = module.example_team_rds.access_key_id
    secret_access_key     = module.example_team_rds.secret_access_key
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.example_team_rds.database_username}:${module.example_team_rds.database_password}@${module.example_team_rds.rds_instance_endpoint}/${module.example_team_rds.database_name}"
     *
     */
}

