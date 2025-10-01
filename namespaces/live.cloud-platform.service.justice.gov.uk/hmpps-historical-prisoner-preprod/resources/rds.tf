module "historical_prisoner_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business_unit             = var.business_unit
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  db_engine                 = "sqlserver-web"
  rds_family                = "sqlserver-web-16.0"
  db_engine_version         = "16.00"
  db_instance_class         = "db.t3.small"
  db_iops                   = 3000
  db_allocated_storage      = 100
  db_max_allocated_storage  = 1000
  environment_name          = var.environment-name
  infrastructure_support    = var.infrastructure_support

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  deletion_protection          = true
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  prepare_for_major_upgrade    = false
  performance_insights_enabled = false
  enable_rds_auto_start_stop   = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "historical_prisoner_rds" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    DB_SERVER            = module.historical_prisoner_rds.rds_instance_endpoint
    DB_USER              = module.historical_prisoner_rds.database_username
    DB_PASS              = module.historical_prisoner_rds.database_password
    rds_instance_address = module.historical_prisoner_rds.rds_instance_address
  }
}
