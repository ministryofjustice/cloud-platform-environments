################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (PostgreSQL)
#################################################################################

module "dex_mi_production_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.small"
  db_max_allocated_storage   = "10000"
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_backup_retention_period = "7"
  db_name                    = "metabase_production"

  rds_family = "postgres12"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dex_mi_production_rds" {
  metadata {
    name      = "dex-mi-production-rds-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.dex_mi_production_rds.rds_instance_endpoint
    database_name         = module.dex_mi_production_rds.database_name
    database_username     = module.dex_mi_production_rds.database_username
    database_password     = module.dex_mi_production_rds.database_password
    rds_instance_address  = module.dex_mi_production_rds.rds_instance_address
    url                   = "postgres://${module.dex_mi_production_rds.database_username}:${module.dex_mi_production_rds.database_password}@${module.dex_mi_production_rds.rds_instance_endpoint}/${module.dex_mi_production_rds.database_name}"
  }
}
