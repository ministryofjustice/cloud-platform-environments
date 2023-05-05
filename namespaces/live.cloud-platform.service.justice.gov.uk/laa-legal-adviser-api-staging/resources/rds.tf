module "rds_11" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.email
  db_engine              = "postgres"
  db_engine_version      = "11"
  db_instance_class      = "db.t2.small"
  db_allocated_storage   = "5"
  db_name                = "laalaa"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  rds_family             = "postgres11"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "database" {
  metadata {
    name      = "database"
    namespace = var.namespace
  }

  data = {
    db_identifier     = module.rds_11.db_identifier
    endpoint          = module.rds_11.rds_instance_endpoint
    name              = module.rds_11.database_name
    user              = module.rds_11.database_username
    password          = module.rds_11.database_password
    host              = module.rds_11.rds_instance_address
    port              = module.rds_11.rds_instance_port
    url               = "postgis://${module.rds_11.database_username}:${module.rds_11.database_password}@${module.rds_11.rds_instance_endpoint}/${module.rds_11.database_name}"
    access_key_id     = module.rds_11.access_key_id
    secret_access_key = module.rds_11.secret_access_key
  }
}
