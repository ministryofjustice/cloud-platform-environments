##
## PostgreSQL - Application Database
##

module "rl_dps_microsvc_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  enable_rds_auto_start_stop = true
  vpc_name                   = var.vpc_name
  namespace                  = var.namespace
  application                = var.application
  business_unit              = var.business_unit
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  is_production              = var.is_production
  team_name                  = var.team_name

  rds_name          = "rl-dps-microsvc-${var.environment}"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13.14"
  db_instance_class = "db.t3.small"
  db_name           = "rl_dps_microsvc"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rl_dps_microsvc_rds" {
  metadata {
    name      = "rl-dps-microsvc-database"
    namespace = var.namespace
  }

  data = {
    host     = module.rl_dps_microsvc_rds.rds_instance_address
    name     = module.rl_dps_microsvc_rds.database_name
    username = module.rl_dps_microsvc_rds.database_username
    password = module.rl_dps_microsvc_rds.database_password
  }
}
