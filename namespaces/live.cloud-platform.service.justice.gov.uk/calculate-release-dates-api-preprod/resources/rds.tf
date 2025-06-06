data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

module "calculate_release_dates_api_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  vpc_name               = var.vpc_name
  db_instance_class      = "db.t3.small"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  db_max_allocated_storage     = "250"
  db_engine              = "postgres"
  db_engine_version      = "16.8"
  rds_family             = "postgres16"
  prepare_for_major_upgrade = false
  allow_minor_version_upgrade = true

  db_password_rotated_date = "14-02-2023"

  providers = {
    aws = aws.london
  }

  vpc_security_group_ids     = [aws_security_group.data_catalogue_access_sg.id, data.aws_security_group.mp_dps_sg.id]

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

resource "aws_security_group" "data_catalogue_access_sg" {
  name        = "${var.namespace}-RDS-DC-Access-SG"
  description = "Security Group for Data Catalogue access to RDS"
  vpc_id      = data.aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }

  ingress{
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.201.128.0/17"]
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "calculate_release_dates_api_rds_refresh_creds" {
  metadata {
    name      = "rds-instance-output-preprod"
    namespace = "calculate-release-dates-api-prod"
  }

  data = {
    rds_instance_endpoint = module.calculate_release_dates_api_rds.rds_instance_endpoint
    database_name         = module.calculate_release_dates_api_rds.database_name
    database_username     = module.calculate_release_dates_api_rds.database_username
    database_password     = module.calculate_release_dates_api_rds.database_password
    rds_instance_address  = module.calculate_release_dates_api_rds.rds_instance_address
  }
}


module "read_replica" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"

  vpc_name               = var.vpc_name
  allow_minor_version_upgrade  = true

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # PostgreSQL specifics
  db_max_allocated_storage     = "250"
  db_engine         = "postgres"
  db_engine_version = "16"
  rds_family        = "postgres16"
  db_instance_class = "db.t3.small"

  # It is mandatory to set the below values to create read replica instance
  # Set the db_identifier of the source db
  replicate_source_db = module.calculate_release_dates_api_rds.db_identifier

  # No backups or snapshots are created for read replica
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

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

resource "kubernetes_secret" "read_replica" {
  metadata {
    name      = "rds-read-replica-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.read_replica.rds_instance_endpoint
    database_name         = module.read_replica.database_name
    database_username     = module.read_replica.database_username
    database_password     = module.read_replica.database_password
    rds_instance_address  = module.read_replica.rds_instance_address
  }
}

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}