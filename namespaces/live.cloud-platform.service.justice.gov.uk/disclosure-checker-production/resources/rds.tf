############################################
# Disclosure Checker RDS (postgres engine)
############################################

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=rds-update-vpc-name"

  cluster_name = var.vpc_name

  application            = var.application
  environment-name       = var.environment_name
  is-production          = var.is_production
  namespace              = var.namespace
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name

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

