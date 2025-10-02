############################################
# Family Mediators API RDS (postgres engine)
############################################

module "rds-instance" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name = var.vpc_name

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  team_name              = var.team_name

  db_instance_class         = "db.t4g.small"
  db_max_allocated_storage  = "10000"
  db_engine                 = "postgres"
  db_engine_version         = "16.8"
  rds_family                = "postgres16"
  prepare_for_major_upgrade = false

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-family-mediators-api-production"
    namespace = var.namespace
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
