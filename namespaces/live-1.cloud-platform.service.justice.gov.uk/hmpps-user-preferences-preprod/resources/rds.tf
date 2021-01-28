variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "hmpps_user_preferences_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  db_engine_version      = "11"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  rds_family = "postgres11"

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
    access_key_id         = module.hmpps_user_preferences_rds.access_key_id
    secret_access_key     = module.hmpps_user_preferences_rds.secret_access_key
    url                   = "postgres://${module.hmpps_user_preferences_rds.database_username}:${module.hmpps_user_preferences_rds.database_password}@${module.hmpps_user_preferences_rds.rds_instance_endpoint}/${module.hmpps_user_preferences_rds.database_name}"
  }
}

