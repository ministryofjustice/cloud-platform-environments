/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/

module "rds_mysql" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # turn off performance insights
  performance_insights_enabled = false

  # general options
  allow_major_version_upgrade = "false"

  # using mysql
  db_engine         = "mysql"
  db_engine_version = "8.0.33"
  rds_family        = "mysql8.0"
  db_instance_class = "db.t4g.small"

  # overwrite db_parameters.
  db_parameter = [
    {
      name         = "character_set_client"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_server"
      value        = "utf8"
      apply_method = "immediate"
    }
  ]

  # Enable auto start and stop of the RDS instances during 10:00 PM - 6:00 AM for cost saving, recommended for non-prod instances
  # enable_rds_auto_start_stop  = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds_mysql" {
  metadata {
    name      = "rds-mysql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mysql.rds_instance_endpoint
    database_name         = module.rds_mysql.database_name
    database_username     = module.rds_mysql.database_username
    database_password     = module.rds_mysql.database_password
    rds_instance_address  = module.rds_mysql.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds_mysql" {
  metadata {
    name      = "rds-mysql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_mysql.database_name
    db_identifier = module.rds_mysql.db_identifier

  }
}
