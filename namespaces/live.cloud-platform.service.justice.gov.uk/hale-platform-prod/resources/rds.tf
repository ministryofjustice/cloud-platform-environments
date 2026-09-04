module "rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  # turn off performance insights
  performance_insights_enabled = false

  # general options
  db_instance_class      = "db.t4g.small"
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = "true"
  backup_window          = "00:31-01:01"

  # using mysql
  db_engine         = "mariadb"
  db_engine_version = "10.11"
  rds_family        = "mariadb10.11"

  # Upgrades
  prepare_for_major_upgrade = false
  # Window for minor version upgrades in UTC.
  # (upgrades and associated backups may cause resource spikes)
  maintenance_window        = "Sun:03:00-Sun:04:00"

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

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier

  }
}
