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

  enable_rds_auto_start_stop = true
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  deletion_protection        = true
  prepare_for_major_upgrade  = true
  rds_family                 = "postgres17"
  db_engine                  = "postgres"
  db_engine_version          = "17.6"
  enable_irsa = true

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

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
