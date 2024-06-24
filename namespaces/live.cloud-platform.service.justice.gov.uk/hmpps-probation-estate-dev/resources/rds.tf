module "rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.0.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  prepare_for_major_upgrade = false
  performance_insights_enabled = true
  db_instance_class            = "db.t4g.small"
  db_engine_version            = "15.5"
  environment_name             = var.environment
  infrastructure_support       = var.infrastructure_support

  rds_family = "postgres15"

  enable_rds_auto_start_stop = true

  providers = {
    aws = aws.london
  }
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
