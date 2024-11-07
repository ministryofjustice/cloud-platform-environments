module "hmpps_hpa_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.0"
  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business_unit             = var.business_unit
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  db_engine                 = "sqlserver-ex"
  db_engine_version         = "16.00"
  db_instance_class         = "db.t3.xlarge"
  db_iops                   = 16000
  db_allocated_storage      = 120
  db_max_allocated_storage  = 250
  environment_name          = var.environment-name
  infrastructure_support    = var.infrastructure_support
  rds_family                = "sqlserver-ex-16.0"
  db_parameter = []
  license_model             = "license-included"
  prepare_for_major_upgrade = false

  performance_insights_enabled = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_hpa_rds" {
  metadata {
    name      = "rds-sqlserver-instance-output"
    namespace = var.namespace
  }

  data = {
    DB_SERVER            = module.hmpps_hpa_rds.rds_instance_endpoint
    DB_USER              = module.hmpps_hpa_rds.database_username
    DB_PASS              = module.hmpps_hpa_rds.database_password
    DB_NAME              = "iis-prod"
    rds_instance_address = module.hmpps_hpa_rds.rds_instance_address
  }
}
