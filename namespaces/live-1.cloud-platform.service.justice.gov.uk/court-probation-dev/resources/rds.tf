variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "court_case_service_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  namespace              = var.namespace
  application            = var.application
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  rds_family             = var.rds-family
  db_engine_version      = var.db_engine_version

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_case_service_rds" {
  metadata {
    name      = "court-case-service-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.court_case_service_rds.rds_instance_endpoint
    database_name         = module.court_case_service_rds.database_name
    database_username     = module.court_case_service_rds.database_username
    database_password     = module.court_case_service_rds.database_password
    rds_instance_address  = module.court_case_service_rds.rds_instance_address
    url                   = "postgres://${module.court_case_service_rds.database_username}:${module.court_case_service_rds.database_password}@${module.court_case_service_rds.rds_instance_endpoint}/${module.court_case_service_rds.database_name}"
    access_key_id         = module.court_case_service_rds.access_key_id
    secret_access_key     = module.court_case_service_rds.secret_access_key
  }
}


