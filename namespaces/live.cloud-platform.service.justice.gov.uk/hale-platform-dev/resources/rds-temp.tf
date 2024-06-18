module "rds-temp" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=migration"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  # turn off performance insights
  performance_insights_enabled = false

  # general options
  db_instance_class           = "db.t4g.small"
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"

  # turn off database outside of work hours - turns off at 10PM and restart it at 6AM UTC (11PM and 7AM BST).
  enable_rds_auto_start_stop = true

  # Used for creation of new RDS instance from snapshot
  is_migration = true

  # using mysql
  db_engine         = "mariadb"
  db_engine_version = "10.4"
  rds_family        = "mariadb10.4"

  # overwrite db_parameters
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

  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:rds:cloud-platform-dea99d9dcfcabb6c-2024-06-15-06-19"

  	
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-temp" {
  metadata {
    name      = "rds-temp-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds-temp.rds_instance_endpoint
    database_name         = module.rds-temp.database_name
    database_username     = module.rds-temp.database_username
    database_password     = module.rds-temp.database_password
    rds_instance_address  = module.rds-temp.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds-temp" {
  metadata {
    name      = "rds-temp-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds-temp.database_name
    db_identifier = module.rds-temp.db_identifier

  }
}
