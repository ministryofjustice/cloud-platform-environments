module "rds2" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  snapshot_identifier = "cloud-platform-bbc8706925e8d35e-2026-07-17-00-36"
  # turn off performance insights
  performance_insights_enabled = false

  # general options
  db_instance_class      = "db.t4g.small"
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # using mysql
  db_engine         = "mariadb"
  db_engine_version = "10.11"
  rds_family        = "mariadb10.11"

  prepare_for_major_upgrade = false

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

resource "kubernetes_secret" "rds2" {
  metadata {
    name      = "rds2-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds2.rds_instance_endpoint
    database_name         = module.rds2.database_name
    database_username     = module.rds2.database_username
    database_password     = module.rds2.database_password
    rds_instance_address  = module.rds2.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds2" {
  metadata {
    name      = "rds2-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds2.database_name
    db_identifier = module.rds2.db_identifier

  }
}
