module "pre_sentence_service_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage        = 20
  storage_type                = "gp3"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  namespace                   = var.namespace
  application                 = "pre-sentence-service"
  rds_name                    = "pre-sentence-service-rds-${var.environment}"
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  is_production               = var.is_production
  rds_family                  = var.rds-family
  db_instance_class           = var.db_instance_class
  db_engine_version           = var.db_engine
  prepare_for_major_upgrade   = true
  allow_major_version_upgrade = true
  enable_rds_auto_start_stop  = true

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
