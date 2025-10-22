module "rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  # VPC configuration
  vpc_name = var.vpc_name

  # Turn off over night
  enable_rds_auto_start_stop = false

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "100"
  db_backup_retention_period   = "35"
  deletion_protection          = true
  enable_irsa = true

  # RDS logging
  opt_in_xsiam_logging  = true

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.medium"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
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