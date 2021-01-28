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
  namespace              = var.namespace
  application            = var.application
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  rds_family             = var.rds-family
  db_engine_version      = var.db_engine_version

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_user_preferences_rds" {
  metadata {
    name      = "court-case-service-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_user_preferences_rds.rds_instance_endpoint
    database_name         = module.hmpps_user_preferences_rds.database_name
    database_username     = module.hmpps_user_preferences_rds.database_username
    database_password     = module.hmpps_user_preferences_rds.database_password
    rds_instance_address  = module.hmpps_user_preferences_rds.rds_instance_address
    url                   = "postgres://${module.hmpps_user_preferences_rds.database_username}:${module.hmpps_user_preferences_rds.database_password}@${module.hmpps_user_preferences_rds.rds_instance_endpoint}/${module.hmpps_user_preferences_rds.database_name}"
    access_key_id         = module.hmpps_user_preferences_rds.access_key_id
    secret_access_key     = module.hmpps_user_preferences_rds.secret_access_key
  }
}


