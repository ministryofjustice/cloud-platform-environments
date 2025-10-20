# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  enable_rds_auto_start_stop = true

  prepare_for_major_upgrade = true
  db_instance_class           = "db.t4g.large"
  rds_family                  = "postgres17"
  db_engine_version           = "17.6"
  deletion_protection         = true
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"

  providers = {
    aws = aws.london
  }

# Add security groups for DPR
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

# Add parameters to enable DPR team to configure replication
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

# To create a read replica, use the below code and update the values to specify the RDS instance
# from which you are replicating. In this example, we're assuming that rds is the
# source RDS instance and read-replica is the replica we are creating.

module "dps_rds_replica" {
  # default off
  count  = 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"

  vpc_name               = var.vpc_name

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # If any other inputs of the RDS is passed in the source db which are different from defaults,
  # add them to the replica

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.6"
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.large"
  # It is mandatory to set the below values to create read replica instance

  # Set the database_name of the source db
  db_name = null # "db_name": conflicts with replicate_source_db

  # Set the db_identifier of the source db
  replicate_source_db = module.dps_rds.db_identifier

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
    },
    {
      name         = "hot_standby_feedback"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  # Add security groups for DPR
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.dps_rds.db_identifier
    resource_id           = module.dps_rds.resource_id
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}

resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "dps-rds-instance-output-preprod"
    namespace = "hmpps-incident-reporting-prod"
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
  }
}

resource "kubernetes_secret" "dps_rds_replica" {
  # default off
  count = 0

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