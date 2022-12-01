variable "cluster_name" {
}

variable "vpc_name" {
}


module "court_case_service_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.13"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business-unit
  namespace                   = var.namespace
  application                 = var.application
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure-support
  allow_major_version_upgrade = false
  db_engine_version           = "13"
  db_instance_class           = "db.t3.small"
  rds_family                  = "postgres13"


  providers = {
    aws = aws.london
  }
}

module "court_case_service_rds_prod_data" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.13"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business-unit
  namespace                   = var.namespace
  application                 = var.application
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure-support
  allow_major_version_upgrade = false
  db_engine_version           = "11"
  db_instance_class           = "db.t3.xlarge"
  rds_family                  = "postgres11"
  rds_name                    = "court-case-service-rds-prod-data"


  snapshot_identifier         = "court-case-service-manual-snapshot-1669738195"
  db_allocated_storage        = 38

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

resource "kubernetes_secret" "court_case_service_rds_prod_data" {
  metadata {
    name      = "court-case-service-rds-instance-output-prod-data"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.court_case_service_rds_prod_data.rds_instance_endpoint
    database_name         = module.court_case_service_rds_prod_data.database_name
    database_username     = module.court_case_service_rds_prod_data.database_username
    database_password     = module.court_case_service_rds_prod_data.database_password
    rds_instance_address  = module.court_case_service_rds_prod_data.rds_instance_address
    url                   = "postgres://${module.court_case_service_rds_prod_data.database_username}:${module.court_case_service_rds_prod_data.database_password}@${module.court_case_service_rds_prod_data.rds_instance_endpoint}/${module.court_case_service_rds_prod_data.database_name}"
    access_key_id         = module.court_case_service_rds_prod_data.access_key_id
    secret_access_key     = module.court_case_service_rds_prod_data.secret_access_key
  }
}

