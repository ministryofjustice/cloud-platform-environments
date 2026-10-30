module "pre_sentence_service_rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  application                  = "pre-sentence-service"
  business_unit                = var.business_unit
  db_allocated_storage         = 10
  db_engine                    = "postgres"
  db_engine_version            = "18.6"
  db_instance_class            = "db.t4g.small"
  enable_rds_auto_start_stop   = true # Stops the RDS 10:00 PM - 6:00 AM for cost saving
  environment_name             = var.environment
  infrastructure_support       = var.infrastructure_support
  is_production                = var.is_production
  namespace                    = var.namespace
  performance_insights_enabled = true
  prepare_for_major_upgrade    = false
  rds_family                   = "postgres18"
  storage_type                 = "gp2"
  allow_major_version_upgrade  = false
  allow_minor_version_upgrade  = true
  team_name                    = var.team_name
  vpc_name                     = var.vpc_name
  
  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "pre_sentence_service_rds" {
  metadata {
    name      = "pre-sentence-service-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.pre_sentence_service_rds.rds_instance_endpoint
    database_name         = module.pre_sentence_service_rds.database_name
    database_username     = module.pre_sentence_service_rds.database_username
    database_password     = module.pre_sentence_service_rds.database_password
    rds_instance_address  = module.pre_sentence_service_rds.rds_instance_address
    url                   = "postgres://${module.pre_sentence_service_rds.database_username}:${module.pre_sentence_service_rds.database_password}@${module.pre_sentence_service_rds.rds_instance_endpoint}/${module.pre_sentence_service_rds.database_name}"
  }
}
