module "hmpps_interventions_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.13"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  rds_family        = "postgres10"
  db_instance_class = "db.m5.large"

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

# Inject pre-prod DB credentials for refresh job running on production
resource "kubernetes_secret" "hmpps_interventions_refresh_secret" {
  metadata {
    name      = "postgres-preprod"
    namespace = "hmpps-interventions-prod"
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
