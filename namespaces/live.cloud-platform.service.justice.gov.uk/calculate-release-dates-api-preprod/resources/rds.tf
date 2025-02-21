module "calculate_release_dates_api_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.2.2"
  vpc_name               = var.vpc_name
  db_instance_class      = "db.t3.small"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  db_engine              = "postgres"
  db_engine_version      = "16.3"
  rds_family             = "postgres16"
  prepare_for_major_upgrade = false

  db_password_rotated_date = "14-02-2023"

  providers = {
    aws = aws.london
  }

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
    }
  ]
}

resource "kubernetes_secret" "calculate_release_dates_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.calculate_release_dates_api_rds.rds_instance_endpoint
    database_name         = module.calculate_release_dates_api_rds.database_name
    database_username     = module.calculate_release_dates_api_rds.database_username
    database_password     = module.calculate_release_dates_api_rds.database_password
    rds_instance_address  = module.calculate_release_dates_api_rds.rds_instance_address
  }
}

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}