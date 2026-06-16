module "manage_offences_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage        = 10
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds_family
  prepare_for_major_upgrade   = true
  allow_major_version_upgrade = "true"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  db_engine                   = "postgres"
  db_engine_version           = "18"

  db_password_rotated_date = "13-02-2023"

  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

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

  providers = {
    aws = aws.london
  }

}

# Retrieve mp_dps_sg_name SG group ID, CP-MP-INGRESS

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

resource "kubernetes_secret" "manage_offences_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.manage_offences_rds.rds_instance_endpoint
    database_name         = module.manage_offences_rds.database_name
    database_username     = module.manage_offences_rds.database_username
    database_password     = module.manage_offences_rds.database_password
    rds_instance_address  = module.manage_offences_rds.rds_instance_address
  }
}
