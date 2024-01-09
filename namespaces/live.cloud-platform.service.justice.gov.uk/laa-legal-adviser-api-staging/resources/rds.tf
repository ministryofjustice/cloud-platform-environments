module "laa_laa_rds_postgres_14" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.email
  db_engine              = "postgres"
  db_engine_version      = "14"
  db_instance_class      = "db.t4g.small"
  db_allocated_storage   = "5"
  db_name                = "laalaa"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  rds_family             = "postgres14"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_laa_rds_postgres_14" {
  metadata {
    name      = "database-14"
    namespace = var.namespace
  }

  data = {
    db_identifier = module.laa_laa_rds_postgres_14.db_identifier
    endpoint      = module.laa_laa_rds_postgres_14.rds_instance_endpoint
    name          = module.laa_laa_rds_postgres_14.database_name
    user          = module.laa_laa_rds_postgres_14.database_username
    password      = module.laa_laa_rds_postgres_14.database_password
    host          = module.laa_laa_rds_postgres_14.rds_instance_address
    port          = module.laa_laa_rds_postgres_14.rds_instance_port
    url           = "postgis://${module.laa_laa_rds_postgres_14.database_username}:${module.laa_laa_rds_postgres_14.database_password}@${module.laa_laa_rds_postgres_14.rds_instance_endpoint}/${module.laa_laa_rds_postgres_14.database_name}"
  }
}
