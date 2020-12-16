variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "oasys-keycloak_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "oasys-keycloak_rds" {
  metadata {
    name      = "oasys-keycloak-rds-instance-output"
    namespace = "oasys-keycloak-development"
  }

  data = {
    rds_instance_endpoint = module.oasys-keycloak_rds.rds_instance_endpoint
    database_name         = module.oasys-keycloak_rds.database_name
    database_username     = module.oasys-keycloak_rds.database_username
    database_password     = module.oasys-keycloak_rds.database_password
    rds_instance_address  = module.oasys-keycloak_rds.rds_instance_address
    url                   = "postgres://${module.oasys-keycloak_rds.database_username}:${module.oasys-keycloak_rds.database_password}@${module.oasys-keycloak_rds.rds_instance_endpoint}/${module.oasys-keycloak_rds.database_name}"
  }
}

