/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name
  vpc_security_group_ids       = [data.aws_security_group.mp_dps_sg.id]

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = true
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Commenting - we want the service to be running 24/7 which is why we are commenting this line.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.
  # Must be false (or unset) for the custom db_parameter group below to be applied
  prepare_for_major_upgrade = false

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.15"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.medium"

  # Datahub (DPR) ingestion via AWS DMS - logical replication. Reboot required.
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    },
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

# Read replica used by Datahub (DPR) for ingestion, to protect the primary
module "read_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name               = var.vpc_name
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # RDS configuration
  rds_name            = "${var.namespace}-read-replica"
  replicate_source_db = module.rds.db_identifier

  # No backups or snapshots are needed for a read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "16.15"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.medium"

  # Datahub (DPR) ingestion via AWS DMS - logical replication. Reboot required.
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    },
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
    },
    {
      name         = "hot_standby_feedback"
      value        = "1"
      apply_method = "immediate"
    }
  ]

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

resource "kubernetes_secret" "read_replica" {
  metadata {
    name      = "rds-postgresql-read-replica-output"
    namespace = var.namespace
  }

  # database_username, database_password and database_name are the same as the source RDS instance
  data = {
    rds_instance_endpoint = module.read_replica.rds_instance_endpoint
    rds_instance_address  = module.read_replica.rds_instance_address
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