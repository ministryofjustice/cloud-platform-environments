/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage = var.db_allocated_storage
  storage_type         = var.storage_type

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = var.allow_minor_version_upgrade
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  prepare_for_major_upgrade    = var.prepare_for_major_upgrade
  performance_insights_enabled = var.performance_insights_enabled
  db_max_allocated_storage     = var.db_max_allocated_storage
  enable_rds_auto_start_stop   = var.enable_rds_auto_start_stop # Comment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  maintenance_window = var.maintenance_window
  backup_window = var.backup_window
  db_parameter = var.db_parameter
  deletion_protection = var.deletion_protection
  
  # PostgreSQL specifics
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  rds_family        = var.rds_family
  db_instance_class = var.db_instance_class

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  enable_irsa = true
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
    rds_url               = "jdbc:postgres://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

# Configmap to store non-sensitive data related to the RDS instance

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}