module "dps_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business_unit             = var.business_unit
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  environment_name          = var.environment-name
  infrastructure_support    = var.infrastructure_support
  db_instance_class         = "db.r6g.large"
  db_iops                   = "12000"
  db_allocated_storage      = "512"
  db_max_allocated_storage     = "2000"
  deletion_protection       = true
  prepare_for_major_upgrade = false
  rds_family                = "postgres16"
  db_engine                 = "postgres"
  db_engine_version         = "16"
  performance_insights_enabled = true
  enable_rds_auto_start_stop   = false

  vpc_security_group_ids     = [data.aws_security_group.mp_dps_sg.id]

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

  enable_irsa = true
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "dps-rds-instance-output-preprod"
    namespace = "offender-case-notes-prod"
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
  }
}

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

module "read_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  vpc_name               = var.vpc_name
  allow_minor_version_upgrade  = true

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  db_engine                 = "postgres"
  db_engine_version         = "16"
  rds_family                = "postgres16"
  db_instance_class         = "db.r6g.large"
  db_iops                   = "12000"
  db_allocated_storage      = "512"
  db_max_allocated_storage  = "2000"

  replicate_source_db = module.dps_rds.db_identifier

  # No backups or snapshots are required for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  vpc_security_group_ids     = [data.aws_security_group.mp_dps_sg.id]

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

resource "kubernetes_secret" "read_replica" {
  metadata {
    name      = "rds-postgresql-read-replica-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.read_replica.rds_instance_endpoint
    rds_instance_address  = module.read_replica.rds_instance_address
    database_name         = module.read_replica.database_name
    database_username     = module.read_replica.database_username
    database_password     = module.read_replica.database_password
  }
}
