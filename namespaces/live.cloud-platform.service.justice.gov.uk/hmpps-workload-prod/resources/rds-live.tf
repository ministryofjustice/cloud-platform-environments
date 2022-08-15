module "rds-live" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.10"
  cluster_name  = var.cluster_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version      = "11"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family    = "postgres11"
  backup_window = "02:00-03:00"

  db_allocated_storage = "150"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-live" {
  metadata {
    name      = "rds-live-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds-live.rds_instance_endpoint
    database_name         = module.rds-live.database_name
    database_username     = module.rds-live.database_username
    database_password     = module.rds-live.database_password
    rds_instance_address  = module.rds-live.rds_instance_address
    access_key_id         = module.rds-live.access_key_id
    secret_access_key     = module.rds-live.secret_access_key
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds-live.database_username}:${module.rds-live.database_password}@${module.rds-live.rds_instance_endpoint}/${module.rds-live.database_name}"
     *
     */
}

resource "kubernetes_config_map" "rds-live" {
  metadata {
    name      = "rds-live-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds-live.database_name
    db_identifier = module.rds-live.db_identifier

  }
}
