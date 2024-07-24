############################################
# Disclosure Checker RDS (postgres engine)
############################################

module "rds-instance" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.0.0"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  environment_name           = var.environment_name
  infrastructure_support     = var.infrastructure_support
  namespace                  = var.namespace
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  db_engine                  = "postgres"
  db_engine_version          = "15"
  rds_family                 = "postgres15"

  enable_rds_auto_start_stop = true
  prepare_for_major_upgrade = false

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-disclosure-checker-staging"
    namespace = var.namespace
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
