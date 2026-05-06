module "rds-snapshot-restore" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  rds_name = "hmpps-alerts-preprod-snapshot-restore-test"
  snapshot_identifier = "alerts-preprod-test-snapshot-20260506"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  prepare_for_major_upgrade    = false
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "250"
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17"
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.medium"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

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
      name         = "max_wal_size"
      value        = "1024"
      apply_method = "immediate"
    },
    {
      name         = "wal_sender_timeout"
      value        = "0"
      apply_method = "immediate"
    },
    {
      name         = "max_slot_wal_keep_size"
      value        = "5000"
      apply_method = "immediate"
    }
  ]

  enable_irsa = true
}

resource "kubernetes_secret" "rds-snapshot-restore" {
  metadata {
    name      = "rds-postgresql-snapshot-restore-instance-output"
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
