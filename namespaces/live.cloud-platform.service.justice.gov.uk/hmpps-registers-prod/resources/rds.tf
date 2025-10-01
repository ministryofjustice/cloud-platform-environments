# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

module "prisons_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.prison-application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  db_instance_class         = "db.t4g.small"
  db_engine                 = "postgres"
  db_engine_version         = "16.8"
  rds_family                = "postgres16"
  db_max_allocated_storage  = "10000"
    # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = true
  prepare_for_major_upgrade = false
  deletion_protection       = true

  providers = {
    aws = aws.london
  }
}

# To create a read replica, use the below code and update the values to specify the RDS instance
# from which you are replicating. In this example, we're assuming that rds is the
# source RDS instance and read-replica is the replica we are creating.

module "dps_rds_replica" {
  # default off
  count  = 1
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  vpc_name               = var.vpc_name

  # Tags
  application            = var.prison-application
  business_unit          = var.business_unit
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # If any other inputs of the RDS is passed in the source db which are different from defaults,
  # add them to the replica

  # PostgreSQL specifics
  prepare_for_major_upgrade   = false
  db_engine         = "postgres"
  db_engine_version = "16.8"
  rds_family        = "postgres16"
  db_instance_class = "db.t4g.small"
  allow_minor_version_upgrade = true
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = null # "db_name": conflicts with replicate_source_db

  # Set the db_identifier of the source db
  replicate_source_db = module.prisons_rds.db_identifier

  # Set to true. No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  # If db_parameter is specified in source rds instance, use the same values.
  # If not specified you dont need to add any. It will use the default values.
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

  # Add security groups for DPR
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]
}

resource "kubernetes_secret" "prisons_rds" {
  metadata {
    name      = "prisons-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prisons_rds.rds_instance_endpoint
    database_name         = module.prisons_rds.database_name
    database_username     = module.prisons_rds.database_username
    database_password     = module.prisons_rds.database_password
    rds_instance_address  = module.prisons_rds.rds_instance_address
  }
}

resource "kubernetes_secret" "dps_rds_replica" {
  # default off
  count = 1

  metadata {
    name      = "dps-rds-read-replica-output"
    namespace = var.namespace
  }

  # The database_username, database_password, database_name values are same as the source RDS instance.
  # Uncomment if count > 0

  data = {
    rds_instance_endpoint = module.dps_rds_replica[0].rds_instance_endpoint
    rds_instance_address  = module.dps_rds_replica[0].rds_instance_address
  }
}