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
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"

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
  db_engine_version        = "19.0.0.0.ru-2025-01.rur-2025-01.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.small"
  storage_type             = "gp2"
  db_allocated_storage     = "100"
  db_name                  = "APXP"
  license_model            = "license-included"
  db_iops                  = 0
  character_set_name       = "WE8MSWIN1252"
  option_group_name        = aws_db_option_group.oracle_apex.name

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
    name      = "rds-apex-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}


# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds_apex" {
  metadata {
    name      = "rds-apex-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}

resource "aws_db_option_group" "oracle_apex" {
  name                     = "${var.namespace}-oracle-apex"
  option_group_description = "Oracle option group with APEX, APEX-DEV and STATSPACK"
  engine_name              = "oracle-ee"
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

  tags = {
    Name          = "${var.namespace}-oracle-apex"
    Environment   = var.environment
    Team          = var.team_name
    Application   = local.application
  }
}

