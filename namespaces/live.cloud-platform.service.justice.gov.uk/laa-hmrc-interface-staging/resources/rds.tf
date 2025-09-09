
module "rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # enable performance insights
  performance_insights_enabled = true

  # Database configuration
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "17.4"
  db_instance_class           = "db.t4g.small"
  rds_family                  = "postgres17"
  allow_minor_version_upgrade = "true"
  allow_major_version_upgrade = "true"
  enable_rds_auto_start_stop  = true

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}
