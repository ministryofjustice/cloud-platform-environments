/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.20.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version = "14"

  # change the instance class as you see fit.
  db_instance_class = "db.t4g.small"

  # rds_family should be one of: postgres10, postgres11, postgres12, postgres13, postgres14
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # Enable auto start and stop of the RDS instances during 10:00 PM - 6:00 AM for cost saving, recommended for non-prod instances
  #
  # Team Note: could be useful but since we are likely to be using overnight
  # scheduled jobs we are not enabling on any environments for now.
  #
  # enable_rds_auto_start_stop  = true

  # This will rotate the db password. Update the value to the current date.
  # db_password_rotated_date  = "dd-mm-yyyy"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier

  }
}
