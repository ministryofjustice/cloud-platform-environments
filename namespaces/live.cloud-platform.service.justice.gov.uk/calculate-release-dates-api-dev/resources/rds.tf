data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

module "calculate_release_dates_api_rds" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage      = 10
  storage_type              = "gp2"
  vpc_name                  = var.vpc_name
  db_instance_class         = "db.t3.small"
  team_name                 = var.team_name
  business_unit             = var.business_unit
  application               = var.application
  is_production             = var.is_production
  namespace                 = var.namespace
  environment_name          = var.environment
  infrastructure_support    = var.infrastructure_support
  db_engine                 = "postgres"
  db_engine_version         = "16"
  rds_family                = "postgres16"
  prepare_for_major_upgrade = false

  db_password_rotated_date = "14-02-2023"

  providers = {
    aws = aws.london
  }


  vpc_security_group_ids = [data.aws_security_group.mp_dps_sg.id, aws_security_group.data_catalogue_access_sg.id]

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

  enable_irsa = true
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

data "aws_security_group" "mp_dps_sg" {
  name = var.mp_dps_sg_name
}
