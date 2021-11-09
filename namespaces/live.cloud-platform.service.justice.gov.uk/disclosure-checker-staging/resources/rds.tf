############################################
# Disclosure Checker RDS (postgres engine)
############################################

module "rds-instance" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # enable performance insights
  performance_insights_enabled = false

  # instance class
  db_instance_class = "db.t3.small"

  # change the postgres version as you see fit.
  db_engine_version = "13"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11, postgres12, postgres13
  # Pick the one that defines the postgres version the best
  rds_family = "postgres13"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

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

