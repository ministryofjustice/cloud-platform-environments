module "rds_tmp" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.0.0"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  namespace     = var.namespace
  is_production = var.is_production

  # turn off performance insights
  performance_insights_enabled = false

  # general options
  db_engine                   = "mariadb"
  db_engine_version           = "10.11.6"
  rds_family                  = "mariadb10.11"
  db_instance_class           = "db.t4g.medium"
  db_allocated_storage        = "5"
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  snapshot_identifier         = "rds:cloud-platform-500c191860718eb0-2024-08-15-04-50"

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

resource "kubernetes_secret" "rds_tmp" {
  metadata {
    name      = "rds-tmp-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_tmp.rds_instance_endpoint
    database_name         = module.rds_tmp.database_name
    database_username     = module.rds_tmp.database_username
    database_password     = module.rds_tmp.database_password
    rds_instance_address  = module.rds_tmp.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds_tmp" {
  metadata {
    name      = "rds-tmp-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_tmp.database_name
    db_identifier = module.rds_tmp.db_identifier
  }
}
