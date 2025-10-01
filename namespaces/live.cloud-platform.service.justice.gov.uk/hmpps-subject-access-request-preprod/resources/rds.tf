module "subject_access_request_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage        = 10
  storage_type                = "gp2"
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
  prepare_for_major_upgrade   = false
  allow_major_version_upgrade = false
  deletion_protection         = true
  performance_insights_enabled = true

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
