/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
 locals {
  application = "apex certificated bailiffs"
}

module "rds_apex" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # Oracle specifics
  db_engine                = "oracle-se2"
  db_engine_version        = "19.0.0.0.ru-2025-04.rur-2025-04.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.small"
  storage_type             = "gp2"
  db_allocated_storage     = "100"
  db_name                  = "APXP"
  license_model            = "license-included"
  db_iops                  = 0
  character_set_name       = "WE8MSWIN1252"
  option_group_name        = aws_db_option_group.oracle_apex.name

  # Avoid default parameters set my MOJ ( rds.force_ssl)
  db_parameter = []

  # Tags
  application            = local.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}


resource "kubernetes_secret" "rds_apex" {
  metadata {
    name      = "rds-apex-oracle-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds_apex.database_name
    database_host         = module.rds_apex.rds_instance_address
    database_port         = module.rds_apex.rds_instance_port
    database_username     = module.rds_apex.database_username
    database_password     = module.rds_apex.database_password
  }
}

resource "aws_db_option_group" "oracle_apex" {
  name                     = "${var.namespace}-oracle-apex"
  option_group_description = "Oracle option group with APEX, APEX-DEV and STATSPACK"
  engine_name              = "oracle-se2"
  major_engine_version     = "19"

  option {
    option_name = "APEX"
    version     = "19.1.v1"
  }

  option {
    option_name = "APEX-DEV"
  }

  option {
    option_name = "STATSPACK"
  }

  option {
    option_name = "S3_INTEGRATION"
  }

  tags = {
    name                   = "${var.namespace}-oracle-apex"
    environment            = var.environment
    team                   = var.team_name
    application            = local.application
    business-unit          = var.business_unit
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    is-production          = var.is_production
    namespace              = var.namespace
    team_name              = var.team_name
  }
}
