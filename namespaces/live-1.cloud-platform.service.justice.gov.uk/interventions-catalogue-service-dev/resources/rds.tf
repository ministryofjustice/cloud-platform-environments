variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "interventions_catalogue_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  db_engine_version      = "11"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  rds_family = "postgres11"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "interventions_catalogue_rds" {
  metadata {
    name      = "interventions-catalogue-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.interventions_catalogue_rds.rds_instance_endpoint
    database_name         = module.interventions_catalogue_rds.database_name
    database_username     = module.interventions_catalogue_rds.database_username
    database_password     = module.interventions_catalogue_rds.database_password
    rds_instance_address  = module.interventions_catalogue_rds.rds_instance_address
    access_key_id         = module.interventions_catalogue_rds.access_key_id
    secret_access_key     = module.interventions_catalogue_rds.secret_access_key
    url                   = "postgres://${module.interventions_catalogue_rds.database_username}:${module.interventions_catalogue_rds.database_password}@${module.interventions_catalogue_rds.rds_instance_endpoint}/${module.interventions_catalogue_rds.database_name}"
  }
}

