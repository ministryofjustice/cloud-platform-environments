########################################
# C100 Application RDS (postgres engine)
########################################

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  vpc_name = var.vpc_name

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  namespace              = var.namespace
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  db_engine_version      = var.db_engine_version
  db_instance_class      = var.db_instance_class
  allow_major_version_upgrade = "true"
  rds_family             = var.db_engine_family

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-c100-production"
    namespace = var.namespace
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
    rds_instance_endpoint = module.rds-instance.rds_instance_endpoint
    database_name         = module.rds-instance.database_name
    database_username     = module.rds-instance.database_username
    database_password     = module.rds-instance.database_password
    rds_instance_address  = module.rds-instance.rds_instance_address
    access_key_id         = module.rds-instance.access_key_id
    secret_access_key     = module.rds-instance.secret_access_key
  }
}
