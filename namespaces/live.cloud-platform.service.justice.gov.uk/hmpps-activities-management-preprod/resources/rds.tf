# Retrieve mp_dps_sg_name SG group ID
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}

module "activities_api_rds" {
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

  # Add security groups for DPR
  vpc_security_group_ids      = [data.aws_security_group.mp_dps_sg.id]

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
    }
  ]

  providers = {
    aws = aws.london
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
  prepare_for_major_upgrade   = true
  rds_family                  = "postgres17"
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "17.2"
  storage_type                = "gp3"
  db_max_allocated_storage    = "200"

  # Add security groups for DPR
  vpc_security_group_ids      = [data.aws_security_group.mp_dps_sg.id]

  # Add parameters to enable DPR team to configure replication
#  db_parameter = [
#    {
#      name         = "rds.logical_replication"
#      value        = "1"
#      apply_method = "pending-reboot"
#    },
#    {
#      name         = "shared_preload_libraries"
#      value        = "pglogical"
#      apply_method = "pending-reboot"
#    },
#    {
#      name         = "max_wal_size"
#      value        = "1024"
#      apply_method = "immediate"
#    },
#    {
#      name         = "wal_sender_timeout"
#      value        = "0"
#      apply_method = "immediate"
#    },
#    {
#      name         = "max_slot_wal_keep_size"
#      value        = "5000"
#      apply_method = "immediate"
#    }
#  ]

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

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "rds_refresh_creds" {
  metadata {
    name      = "rds-instance-output-preprod"
    namespace = "hmpps-activities-management-prod"
  }

  data = {
    database_name        = module.activities_rds.database_name
    database_username    = module.activities_rds.database_username
    database_password    = module.activities_rds.database_password
    rds_instance_address = module.activities_rds.rds_instance_address
  }
}
