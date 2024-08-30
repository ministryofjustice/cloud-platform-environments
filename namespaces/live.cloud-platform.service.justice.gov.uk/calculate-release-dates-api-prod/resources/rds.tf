module "calculate_release_dates_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                = "postgres"
  db_engine_version        = "13.3"
  rds_family               = "postgres13"
  db_instance_class        = "db.t4g.xlarge"
  db_max_allocated_storage = "1000"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "calculate_release_dates_rds" {
  metadata {
    name      = "calculate-release-dates-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.calculate_release_dates_rds.rds_instance_endpoint
    database_name         = module.calculate_release_dates_rds.database_name
    database_username     = module.calculate_release_dates_rds.database_username
    database_password     = module.calculate_release_dates_rds.database_password
    rds_instance_address  = module.calculate_release_dates_rds.rds_instance_address
    url                   = "postgres://${module.calculate_release_dates_rds.database_username}:${module.calculate_release_dates_rds.database_password}@${module.calculate_release_dates_rds.rds_instance_endpoint}/${module.calculate_release_dates_rds.database_name}"
  }
}
