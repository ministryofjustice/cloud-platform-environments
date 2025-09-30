module "dps_rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business_unit                = var.business_unit
  application                  = var.application
  is_production                = var.is_production
  namespace                    = var.namespace
  environment_name             = var.environment-name
  infrastructure_support       = var.infrastructure_support
  db_instance_class            = "db.t4g.medium"
  db_allocated_storage         = "64"
  db_max_allocated_storage     = "1000"
  deletion_protection          = true
  prepare_for_major_upgrade    = false
  rds_family                   = "postgres16"
  db_engine                    = "postgres"
  db_engine_version            = "16"
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
      value        = "5000"
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

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
