############################################
# Disclosure Checker RDS (postgres engine)
############################################

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name = var.vpc_name

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  team_name              = var.team_name

  db_instance_class        = "db.t4g.small"
  db_max_allocated_storage = "10000"
  db_engine                = "postgres"
  db_engine_version        = "14"
  rds_family               = "postgres14"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-disclosure-checker-production"
    namespace = var.namespace
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
