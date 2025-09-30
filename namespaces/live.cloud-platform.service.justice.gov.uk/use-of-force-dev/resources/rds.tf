module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment-name
  infrastructure_support      = var.infrastructure_support

  prepare_for_major_upgrade   = false
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "16.4"
  rds_family                  = "postgres16"
  db_password_rotated_date    = "14-02-2023"
  enable_rds_auto_start_stop = true
  

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

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
