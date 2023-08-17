/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "14.7"
  rds_family        = "postgres14"
  db_instance_class = "db.t4g.micro"
  db_parameter = [
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pglogical"
      apply_method = "pending-reboot"
    },
    {
      name         = "wal_keep_size"
      value        = "64"
      apply_method = "immediate"
    },
    {
      name         = "max_slot_wal_keep_size"
      value        = "64"
      apply_method = "immediate"
    }
  ]

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    url      = "jdbc:postgresql://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
    username = module.rds.database_username
    password = module.rds.database_password
  }
}
