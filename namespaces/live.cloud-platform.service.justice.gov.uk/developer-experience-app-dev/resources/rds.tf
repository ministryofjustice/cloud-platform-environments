module "rds_instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                = "postgres"
  db_engine_version        = "17"
  rds_family               = "postgres17"
  db_instance_class        = "db.t4g.small"
  db_max_allocated_storage = "20"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-devx-app-dev"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_instance.rds_instance_endpoint
    database_name         = module.rds_instance.database_name
    database_username     = module.rds_instance.database_username
    database_password     = module.rds_instance.database_password
    rds_instance_address  = module.rds_instance.rds_instance_address
  }
}
