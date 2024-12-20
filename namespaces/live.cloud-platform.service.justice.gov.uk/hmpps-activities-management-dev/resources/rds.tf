# Retrieve mp_dps_sg_name SG group ID
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

resource "aws_db_parameter_group" "replication_params" {
  name        = "shared-postgres-params"
  family      = var.rds_family
  description = "Custom parameter group for replication parameters thats shared between main rds and the read replica"

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pglogical"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_wal_size"
    value        = "1024"
    apply_method = "immediate"
  }

  parameter {
    name         = "wal_sender_timeout"
    value        = "0"
    apply_method = "immediate"
  }

  parameter {
    name         = "max_slot_wal_keep_size"
    value        = "5000"
    apply_method = "immediate"
  }
}

resource "kubernetes_secret" "activities_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.activities_rds.rds_instance_endpoint
    database_name         = module.activities_rds.database_name
    database_username     = module.activities_rds.database_username
    database_password     = module.activities_rds.database_password
    rds_instance_address  = module.activities_rds.rds_instance_address
  }
}

module "activities_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "14"
  storage_type                = "gp3"
  db_max_allocated_storage    = "50"

  # Add security groups for DPR
  vpc_security_group_ids      = [data.aws_security_group.mp_dps_sg.id]

  # Add replication parameters
  parameter_group_name  = aws_db_parameter_group.replication_params.name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "activities_rds" {
  metadata {
    name      = "activities-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.activities_rds.rds_instance_endpoint
    database_name         = module.activities_rds.database_name
    database_username     = module.activities_rds.database_username
    database_password     = module.activities_rds.database_password
    rds_instance_address  = module.activities_rds.rds_instance_address
  }
}

module "activities_rds_read_replica" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "14"
  storage_type                = "gp3"
  db_max_allocated_storage    = "50"

  replicate_source_db         = module.activities_rds.db_identifier
  skip_final_snapshot         = "true"
  db_backup_retention_period  = 0
  
  # Add security groups for DPR
  vpc_security_group_ids      = [data.aws_security_group.mp_dps_sg.id]

  # Add replication parameters
  parameter_group_name  = aws_db_parameter_group.replication_params.name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "activities_rds_read_replica" {
  metadata {
    name      = "activities-rds-read-replica"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.activities_rds_read_replica.rds_instance_endpoint
    rds_instance_address  = module.activities_rds_read_replica.rds_instance_address
  }
}