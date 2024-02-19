# PostgreSQL

module "rds_postgresql" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  # VPC configuration
  vpc_name                     = var.vpc_name
  allow_major_version_upgrade  = false
  allow_minor_version_upgrade  = false
  backup_window                = "03:46-04:16"
  db_allocated_storage         = "10"
  db_backup_retention_period   = "7"
  db_engine                    = "postgres"
  db_engine_version            = "14.7"
  db_instance_class            = "db.t4g.micro"
  db_max_allocated_storage     = "100"
  db_parameter                 = []
  db_password_rotated_date     = "2023-09-05"
  deletion_protection          = true
  enable_rds_auto_start_stop   = true
  maintenance_window           = "Mon:00:00-Mon:03:00"
  performance_insights_enabled = true
  rds_family                   = "postgres14"
  skip_final_snapshot          = false

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_postgresql.rds_instance_endpoint
    database_name         = module.rds_postgresql.database_name
    database_username     = module.rds_postgresql.database_username
    database_password     = module.rds_postgresql.database_password
    rds_instance_address  = module.rds_postgresql.rds_instance_address
  }
}
