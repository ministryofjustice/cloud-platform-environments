module "hpa_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.0"
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
  db_allocated_storage      = 20
  db_max_allocated_storage  = 100
  environment_name          = var.environment-name
  infrastructure_support    = var.infrastructure_support

  deletion_protection          = true
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  prepare_for_major_upgrade    = false
  performance_insights_enabled = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hpa_rds" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    DB_SERVER            = module.hpa_rds.rds_instance_endpoint
    DB_USER              = module.hpa_rds.database_username
    DB_PASS              = module.hpa_rds.database_password
    rds_instance_address = module.hpa_rds.rds_instance_address
  }
}
