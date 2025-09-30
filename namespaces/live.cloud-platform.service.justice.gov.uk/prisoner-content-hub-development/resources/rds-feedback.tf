module "prisoner_feedback_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "17"
  rds_family                  = "postgres17"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "20"
  enable_rds_auto_start_stop   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_feedback_rds" {
  metadata {
    name      = "prisoner-feedback-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prisoner_feedback_rds.rds_instance_endpoint
    database_name         = module.prisoner_feedback_rds.database_name
    database_username     = module.prisoner_feedback_rds.database_username
    database_password     = module.prisoner_feedback_rds.database_password
    rds_instance_address  = module.prisoner_feedback_rds.rds_instance_address
  }
}
