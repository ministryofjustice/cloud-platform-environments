module "rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.2"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  # turn off performance insights
  performance_insights_enabled = false

  # general options
  db_engine                   = "mariadb"
  db_engine_version           = "10.11.6"
  rds_family                  = "mariadb10.11"
  db_instance_class           = "db.t4g.medium"
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"

  # turn off database outside of work hours - turns off at 10PM and restart it at 6AM UTC (11PM and 7AM BST).
  enable_rds_auto_start_stop = true

  # overwrite db_parameters
  db_parameter = [
    {
      name         = "character_set_client"
      value        = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "immediate"
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}
