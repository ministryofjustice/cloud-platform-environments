module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=upgrade-storage-type"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  db_allocated_storage         = "400"
  storage_type                 = "gp3"

  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine            = "sqlserver-ex"
  db_engine_version    = "15.00.4236.7.v1"
  rds_family           = "sqlserver-ex-15.0"
  db_instance_class    = "db.t3.small"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}