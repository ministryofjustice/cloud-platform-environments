module "subject_access_request_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.2.2"

  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  db_instance_class           = "db.t4g.small"
  db_engine                   = "postgres"
  db_engine_version           = "17"
  rds_family                  = "postgres17"
  allow_major_version_upgrade = true
  deletion_protection         = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "subject_access_request_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.subject_access_request_rds.rds_instance_endpoint
    database_name         = module.subject_access_request_rds.database_name
    database_username     = module.subject_access_request_rds.database_username
    database_password     = module.subject_access_request_rds.database_password
    rds_instance_address  = module.subject_access_request_rds.rds_instance_address
  }
}
