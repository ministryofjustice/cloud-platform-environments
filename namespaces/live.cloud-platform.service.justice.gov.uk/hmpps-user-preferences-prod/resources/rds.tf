module "hmpps_user_preferences_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  db_engine_version      = var.db_engine_version
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  rds_family             = var.rds_family

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_user_preferences_rds" {
  metadata {
    name      = "hmpps-user-preferences-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_user_preferences_rds.rds_instance_endpoint
    database_name         = module.hmpps_user_preferences_rds.database_name
    database_username     = module.hmpps_user_preferences_rds.database_username
    database_password     = module.hmpps_user_preferences_rds.database_password
    rds_instance_address  = module.hmpps_user_preferences_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_user_preferences_rds.database_username}:${module.hmpps_user_preferences_rds.database_password}@${module.hmpps_user_preferences_rds.rds_instance_endpoint}/${module.hmpps_user_preferences_rds.database_name}"
  }
}
