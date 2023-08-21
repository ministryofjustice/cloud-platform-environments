module "calculate_release_dates_api_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  db_instance_class      = "db.t3.small"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  db_engine              = "postgres"
  db_engine_version      = "13"
  rds_family             = "postgres13"

  db_password_rotated_date = "17-02-2023"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "calculate_release_dates_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.calculate_release_dates_api_rds.rds_instance_endpoint
    database_name         = module.calculate_release_dates_api_rds.database_name
    database_username     = module.calculate_release_dates_api_rds.database_username
    database_password     = module.calculate_release_dates_api_rds.database_password
    rds_instance_address  = module.calculate_release_dates_api_rds.rds_instance_address
    access_key_id         = module.calculate_release_dates_api_rds.access_key_id
    secret_access_key     = module.calculate_release_dates_api_rds.secret_access_key
  }
}
