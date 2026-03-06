module "rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business_unit                = var.business_unit
  application                  = var.application
  is_production                = var.is_production
  environment_name             = var.environment_name
  infrastructure_support       = var.infrastructure_support
  namespace                    = var.namespace
  rds_name                     = "hmpps-tier-${var.environment_name}"
  rds_family                   = "postgres17"
  db_engine_version            = "17"
  db_instance_class            = "db.t4g.small"
  prepare_for_major_upgrade    = false
  allow_major_version_upgrade  = false
  allow_minor_version_upgrade  = true
  performance_insights_enabled = true
  maintenance_window           = var.maintenance_window
  backup_window                = var.backup_window
  db_password_rotated_date     = "21-02-2023"
}

resource "kubernetes_secret" "rds-secret" {
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
