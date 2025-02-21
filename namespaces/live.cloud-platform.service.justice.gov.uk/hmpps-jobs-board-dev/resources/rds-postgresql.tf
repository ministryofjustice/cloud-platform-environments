module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.2.2"

  # Add security group id
  vpc_security_group_ids       = [data.aws_security_group.mp_dps_sg.id]

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.2"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # add parameter group
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
        value        = "40000"
        apply_method = "immediate"
      }
  ]
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

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
