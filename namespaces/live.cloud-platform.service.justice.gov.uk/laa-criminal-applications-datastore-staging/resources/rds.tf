module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version = "14"

  # change the instance class as you see fit.
  db_instance_class = "db.t4g.small"

  # rds_family should be one of: postgres10, postgres11, postgres12, postgres13, postgres14
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key

    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-instance"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}
