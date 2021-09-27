module "rds-mssql" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # performance insights
  performance_insights_enabled = false

  # RDS SQL Server
  db_engine            = "sqlserver-se"
  db_engine_version    = "15.00"
  rds_family           = "sqlserver-se-15.0"
  db_parameter         = []
  db_instance_class      = "db.t3.xlarge"
  db_allocated_storage   = 32
  license_model        = "license-included"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds-mssql.rds_instance_endpoint
    database_name         = module.rds-mssql.database_name
    database_username     = module.rds-mssql.database_username
    database_password     = module.rds-mssql.database_password
    rds_instance_address  = module.rds-mssql.rds_instance_address
    access_key_id         = module.rds-mssql.access_key_id
    secret_access_key     = module.rds-mssql.secret_access_key
  }

}

resource "kubernetes_config_map" "rds-mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds-mssql.database_name
    db_identifier = module.rds-mssql.db_identifier
  }
}