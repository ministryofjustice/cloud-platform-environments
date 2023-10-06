module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # enable performance insights
  performance_insights_enabled = false

  # change the postgres version as you see fit.
  db_engine         = "postgres"
  db_engine_version = "15"

  # change the instance class as you see fit.
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500"

  # Pick the one that defines the postgres version the best
  rds_family = "postgres15"

  # use "prepare_for_major_upgrade" when upgrading the major version of an engine
  prepare_for_major_upgrade = false

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

    # postgres://user:password@host:port/name
    url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
    # jdbc:postgresql://host:port/name?user=user&password=password
    jdbc_url = "jdbc:postgresql://${module.rds.rds_instance_endpoint}/${module.rds.database_name}?user=${module.rds.database_username}&password=${module.rds.database_password}"
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
