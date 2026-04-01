module "hmpps_hdc_api_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage   = 10
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  db_instance_class            = "db.t4g.small"
  db_engine_version            = "17.5"
  rds_family                   = "postgres17"
  db_password_rotated_date     = "14-02-2023"
  deletion_protection          = true
  enable_rds_auto_start_stop   = true
  prepare_for_major_upgrade    = false

  providers = {
    aws = aws.london
  }

  # DPR security group
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  # DPR specific parameters
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

resource "kubernetes_secret" "hmpps_hdc_api_rds" {
  metadata {
    name      = "hmpps-hdc-api-rds-secret"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_hdc_api_rds.rds_instance_endpoint
    database_name         = module.hmpps_hdc_api_rds.database_name
    database_username     = module.hmpps_hdc_api_rds.database_username
    database_password     = module.hmpps_hdc_api_rds.database_password
    rds_instance_address  = module.hmpps_hdc_api_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_hdc_api_rds.database_username}:${module.hmpps_hdc_api_rds.database_password}@${module.hmpps_hdc_api_rds.rds_instance_endpoint}/${module.hmpps_hdc_api_rds.database_name}"
  }
}

# DPR security group
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
