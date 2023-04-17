module "hmpps_interventions_postgres14" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  rds_family                  = "postgres14"
  db_engine_version           = "14"
  db_instance_class           = "db.m5.large"
  db_allocated_storage        = 20
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_interventions_postgres14" {
  metadata {
    name      = "postgres14"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_interventions_postgres14.rds_instance_endpoint
    database_name         = module.hmpps_interventions_postgres14.database_name
    database_username     = module.hmpps_interventions_postgres14.database_username
    database_password     = module.hmpps_interventions_postgres14.database_password
    rds_instance_address  = module.hmpps_interventions_postgres14.rds_instance_address
    access_key_id         = module.hmpps_interventions_postgres14.access_key_id
    secret_access_key     = module.hmpps_interventions_postgres14.secret_access_key
    url                   = "postgres://${module.hmpps_interventions_postgres14.database_username}:${module.hmpps_interventions_postgres14.database_password}@${module.hmpps_interventions_postgres14.rds_instance_endpoint}/${module.hmpps_interventions_postgres14.database_name}"
  }
}

# Inject pre-prod DB credentials for refresh job running on production
resource "kubernetes_secret" "hmpps_interventions_refresh14_secret" {
  metadata {
    name      = "postgres14-preprod"
    namespace = "hmpps-interventions-prod"
  }

  data = {
    rds_instance_endpoint = module.hmpps_interventions_postgres14.rds_instance_endpoint
    database_name         = module.hmpps_interventions_postgres14.database_name
    database_username     = module.hmpps_interventions_postgres14.database_username
    database_password     = module.hmpps_interventions_postgres14.database_password
    rds_instance_address  = module.hmpps_interventions_postgres14.rds_instance_address
    access_key_id         = module.hmpps_interventions_postgres14.access_key_id
    secret_access_key     = module.hmpps_interventions_postgres14.secret_access_key
    url                   = "postgres://${module.hmpps_interventions_postgres14.database_username}:${module.hmpps_interventions_postgres14.database_password}@${module.hmpps_interventions_postgres14.rds_instance_endpoint}/${module.hmpps_interventions_postgres14.database_name}"
  }
}
