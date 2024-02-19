########################################
# C100 Application RDS (postgres engine)
########################################

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name = var.vpc_name

  application                 = var.application
  environment_name            = var.environment-name
  is_production               = var.is_production
  namespace                   = var.namespace
  infrastructure_support      = var.infrastructure_support
  team_name                   = var.team_name
  business_unit               = var.business_unit
  db_engine_version           = var.db_engine_version
  db_instance_class           = var.db_instance_class
  allow_major_version_upgrade = "true"
  rds_family                  = var.db_engine_family

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
    url                   = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
    rds_instance_endpoint = module.rds-instance.rds_instance_endpoint
    database_name         = module.rds-instance.database_name
    database_username     = module.rds-instance.database_username
    database_password     = module.rds-instance.database_password
    rds_instance_address  = module.rds-instance.rds_instance_address
  }
}
