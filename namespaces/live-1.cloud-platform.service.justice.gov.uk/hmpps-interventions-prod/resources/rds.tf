module "hmpps_interventions_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  rds_family             = var.rds_family

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_interventions_rds" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_interventions_rds.rds_instance_endpoint
    database_name         = module.hmpps_interventions_rds.database_name
    database_username     = module.hmpps_interventions_rds.database_username
    database_password     = module.hmpps_interventions_rds.database_password
    rds_instance_address  = module.hmpps_interventions_rds.rds_instance_address
    access_key_id         = module.hmpps_interventions_rds.access_key_id
    secret_access_key     = module.hmpps_interventions_rds.secret_access_key
    url                   = "postgres://${module.hmpps_interventions_rds.database_username}:${module.hmpps_interventions_rds.database_password}@${module.hmpps_interventions_rds.rds_instance_endpoint}/${module.hmpps_interventions_rds.database_name}"
  }
}
