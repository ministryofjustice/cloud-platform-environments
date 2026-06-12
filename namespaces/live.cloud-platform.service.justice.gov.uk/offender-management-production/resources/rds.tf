/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "allocation-rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 20
  storage_type         = "gp3"

  vpc_name                    = var.vpc_name
  db_instance_class           = "db.m5.large"
  team_name                   = "offender-management"
  business_unit               = "HMPPS"
  application                 = "offender-management-allocation-manager"
  is_production               = "true"
  namespace                   = var.namespace
  environment_name            = "production"
  infrastructure_support      = "manage-pom-cases@digital.justice.gov.uk"
  db_engine                   = "postgres"
  db_engine_version           = "17.6"
  rds_family                  = "postgres17"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false
  db_name                     = "allocations"

  db_password_rotated_date = "2023-04-05T11:31:27Z"
  
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

resource "kubernetes_secret" "allocation-rds" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = "offender-management-production"
  }

  data = {
    rds_instance_endpoint = module.allocation-rds.rds_instance_endpoint
    rds_instance_address  = module.allocation-rds.rds_instance_address
    database_name         = module.allocation-rds.database_name
    database_username     = module.allocation-rds.database_username
    database_password     = module.allocation-rds.database_password
    postgres_name         = module.allocation-rds.database_name
    postgres_host         = module.allocation-rds.rds_instance_address
    postgres_user         = module.allocation-rds.database_username
    postgres_password     = module.allocation-rds.database_password
  }
}

module "allocation-rds-read-replica" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 20
  storage_type         = "gp3"

  vpc_name                    = var.vpc_name
  db_instance_class           = "db.m5.large"
  team_name                   = "offender-management"
  business_unit               = "HMPPS"
  application                 = "offender-management-allocation-manager"
  is_production               = "true"
  namespace                   = var.namespace
  environment_name            = "production"
  infrastructure_support      = "manage-pom-cases@digital.justice.gov.uk"
  db_engine                   = "postgres"
  db_engine_version           = "17.6"
  rds_family                  = "postgres17"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false
  db_name                     = "allocations"
  db_password_rotated_date = "2023-04-05T11:31:27Z"
  
  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id]

  replicate_source_db        = module.allocation-rds.db_identifier
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0
    
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

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "allocation-rds-read-replica" {
  metadata {
    name      = "allocation-rds-read-replica-instance-output"
    namespace = "offender-management-production"
  }

  data = {
    rds_instance_endpoint = module.allocation-rds-read-replica.rds_instance_endpoint
    rds_instance_address  = module.allocation-rds-read-replica.rds_instance_address
    database_name         = module.allocation-rds-read-replica.database_name
    database_username     = module.allocation-rds-read-replica.database_username
    database_password     = module.allocation-rds-read-replica.database_password
    postgres_name         = module.allocation-rds-read-replica.database_name
    postgres_host         = module.allocation-rds-read-replica.rds_instance_address
    postgres_user         = module.allocation-rds-read-replica.database_username
    postgres_password     = module.allocation-rds-read-replica.database_password
  }
}

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
