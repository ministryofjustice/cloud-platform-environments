module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit

  backup_window      = var.backup_window
  maintenance_window = var.maintenance_window

  performance_insights_enabled = true

  db_allocated_storage = 200
  db_instance_class    = "db.t4g.2xlarge"

  db_engine         = "postgres"
  db_engine_version = "16.8"
  rds_family        = "postgres16"

  prepare_for_major_upgrade = false
  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "false"

  db_parameter = [
    {
      "apply_method" : "immediate",
      "name" : "log_min_duration_statement",
      "value" : "2000"
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
    }
  ]

  enable_irsa = true
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}

module "rds-read-replica" {
  source       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  storage_type = "gp2"

  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  db_allocated_storage   = 200
  db_instance_class      = "db.t4g.medium"

  replicate_source_db = module.rds-instance.db_identifier

  # Set to true for replica database. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  prepare_for_major_upgrade = false
  db_engine_version         = "16.8"
  rds_family                = "postgres16"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }


  # Add security groups for DPR
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  enable_irsa = true
}

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

resource "kubernetes_secret" "rds-read-replica" {
  metadata {
    name      = "read-rds-instance-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-read-replica.rds_instance_endpoint}/${module.rds-read-replica.database_name}"
  }
}
