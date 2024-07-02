module "rds_postgres" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                  = "postgres"
  db_engine_version          = "16"
  rds_family                 = "postgres16"
  db_instance_class          = "db.t4g.small"
  db_max_allocated_storage   = "500"
  enable_rds_auto_start_stop = true
  prepare_for_major_upgrade  = false

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds_postgres" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_postgres.rds_instance_endpoint
    database_name         = module.rds_postgres.database_name
    database_username     = module.rds_postgres.database_username
    database_password     = module.rds_postgres.database_password
    rds_instance_address  = module.rds_postgres.rds_instance_address
  }
}
