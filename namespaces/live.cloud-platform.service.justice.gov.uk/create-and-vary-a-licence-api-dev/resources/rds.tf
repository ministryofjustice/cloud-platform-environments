module "create_and_vary_a_licence_api_rds" {
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
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false
  enable_rds_auto_start_stop  = true
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "17.5"
  rds_family                  = "postgres17"
  db_password_rotated_date    = "14-02-2023"

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

resource "kubernetes_secret" "create_and_vary_a_licence_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.create_and_vary_a_licence_api_rds.rds_instance_endpoint
    database_name         = module.create_and_vary_a_licence_api_rds.database_name
    database_username     = module.create_and_vary_a_licence_api_rds.database_username
    database_password     = module.create_and_vary_a_licence_api_rds.database_password
    rds_instance_address  = module.create_and_vary_a_licence_api_rds.rds_instance_address
  }
}

module "create_and_vary_a_licence_api_read_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name                    = var.vpc_name
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false
  enable_rds_auto_start_stop  = true

  # Tags
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # PostgreSQL specifics
  db_engine            = "postgres"
  db_engine_version    = "17.5"
  rds_family           = "postgres17"
  db_instance_class    = "db.t4g.small"
  db_allocated_storage = 10
  storage_type         = "gp2"

  # Read replica specifics
  replicate_source_db        = module.create_and_vary_a_licence_api_rds.db_identifier
  skip_final_snapshot        = true
  db_backup_retention_period = 0

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
    },
    {
      name         = "hot_standby_feedback"
      value        = "1"
      apply_method = "immediate"
    }
  ]

  enable_irsa = true
}

resource "kubernetes_secret" "create_and_vary_a_licence_api_read_replica" {
  metadata {
    name      = "rds-read-replica-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.create_and_vary_a_licence_api_read_replica.rds_instance_endpoint
    database_name         = module.create_and_vary_a_licence_api_read_replica.database_name
    database_username     = module.create_and_vary_a_licence_api_read_replica.database_username
    database_password     = module.create_and_vary_a_licence_api_read_replica.database_password
    rds_instance_address  = module.create_and_vary_a_licence_api_read_replica.rds_instance_address
  }
}

# DPR security group
data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
