module "rds_postgres14" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true
  # instance class
  db_instance_class = "db.t4g.small"
  
  # change the postgres version as you see fit.
  db_engine_version      = "14"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support

  rds_family = "postgres14"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds_postgres14" {
  metadata {
    name      = "rds-postgres14-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_postgres14.rds_instance_endpoint
    database_name         = module.rds_postgres14.database_name
    database_username     = module.rds_postgres14.database_username
    database_password     = module.rds_postgres14.database_password
    rds_instance_address  = module.rds_postgres14.rds_instance_address
    access_key_id         = module.rds_postgres14.access_key_id
    secret_access_key     = module.rds_postgres14.secret_access_key
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds_postgres14.database_username}:${module.rds_postgres14.database_password}@${module.rds_postgres14.rds_instance_endpoint}/${module.rds_postgres14.database_name}"
     *
     */
}

resource "kubernetes_config_map" "rds_postgres14" {
  metadata {
    name      = "rds-postgres14-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_postgres14.database_name
    db_identifier = module.rds_postgres14.db_identifier

  }
}
