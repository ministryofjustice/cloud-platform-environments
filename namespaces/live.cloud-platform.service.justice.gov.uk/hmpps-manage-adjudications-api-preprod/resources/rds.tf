module "ma_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support

  enable_rds_auto_start_stop = true

  db_instance_class           = "db.t4g.small"
  rds_family                  = "postgres17"
  db_engine_version           = "17.6"
  deletion_protection         = true
  db_engine                   = "postgres"
  db_password_rotated_date    = "15-02-2023"
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  prepare_for_major_upgrade   = false
  db_allocated_storage        = "1500"
  enable_irsa                 = true

  providers = {
    aws = aws.london
  }

  vpc_security_group_ids       = [data.aws_security_group.mp_dps_sg.id]

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

module "rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  is_migration                = true

  enable_rds_auto_start_stop = true

  db_name                     = "db6c035586d92ac925"
  db_instance_class           = "db.t4g.small"
  rds_family                  = "postgres15"
  db_engine_version           = "15.15"
  deletion_protection         = false
  db_engine                   = "postgres"
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = true
  prepare_for_major_upgrade   = false
  db_allocated_storage        = "2000"
  enable_irsa                 = true

  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:cloud-platform-bda2b0e455edefc4-final-23-02-26" ## DO NOT REMOVE UNTIL LOOPING RDS RE-CREATE ISSUE IS RESOLVED

  providers = {
    aws = aws.london
  }

  vpc_security_group_ids       = [data.aws_security_group.mp_dps_sg.id]

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

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "ma-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    db_identifier         = module.rds.db_identifier
    resource_id           = module.rds.resource_id
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    url                   = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "ma-rds-instance-output-preprod"
    namespace = "hmpps-manage-adjudications-api-prod"
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
}

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}