module "hmpps_interventions_onboarding_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=rds-update-vpc-name"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  db_instance_class           = "db.t4g.small"
  rds_family                  = "postgres14"
  db_engine_version           = "14"
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_interventions_onboarding_rds" {
  metadata {
    name      = "onboarding-postgres"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_interventions_onboarding_rds.rds_instance_endpoint
    database_name         = module.hmpps_interventions_onboarding_rds.database_name
    database_username     = module.hmpps_interventions_onboarding_rds.database_username
    database_password     = module.hmpps_interventions_onboarding_rds.database_password
    rds_instance_address  = module.hmpps_interventions_onboarding_rds.rds_instance_address
    access_key_id         = module.hmpps_interventions_onboarding_rds.access_key_id
    secret_access_key     = module.hmpps_interventions_onboarding_rds.secret_access_key
    url                   = "postgres://${module.hmpps_interventions_onboarding_rds.database_username}:${module.hmpps_interventions_onboarding_rds.database_password}@${module.hmpps_interventions_onboarding_rds.rds_instance_endpoint}/${module.hmpps_interventions_onboarding_rds.database_name}"
  }
}
