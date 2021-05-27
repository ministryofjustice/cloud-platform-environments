module "sql-server-main" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.1"
  cluster_name  = var.cluster_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true


  rds_family             = "sqlserver-ex"
  db_engine_version      = "11"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "sql-server-main" {
  metadata {
    name      = "sql-server-main"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
  }
}

resource "kubernetes_config_map" "sql-server-main" {
  metadata {
    name      = "sql-server-main"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}
