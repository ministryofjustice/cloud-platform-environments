module "rds-allocation" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  # rotating creds
  db_password_rotated_date = "09-02-2023"

  # enable performance insights
  performance_insights_enabled = true
  # instance class
  db_instance_class = "db.t4g.small"

  # change the postgres version as you see fit.
  db_engine_version      = "14"
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

  enable_rds_auto_start_stop = true

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-allocation" {
  metadata {
    name      = "rds-allocation-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds-allocation.rds_instance_endpoint
    database_name         = module.rds-allocation.database_name
    database_username     = module.rds-allocation.database_username
    database_password     = module.rds-allocation.database_password
    rds_instance_address  = module.rds-allocation.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds-allocation.database_username}:${module.rds-allocation.database_password}@${module.rds-allocation.rds_instance_endpoint}/${module.rds-allocation.database_name}"
     *
     */
}

resource "kubernetes_config_map" "rds-allocation" {
  metadata {
    name      = "rds-allocation-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds-allocation.database_name
    db_identifier = module.rds-allocation.db_identifier

  }
}
