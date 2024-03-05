################################################################################
# contact-moj
# Application RDS (PostgreSQL)
#################################################################################

module "contact-moj_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.2"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.small"
  db_max_allocated_storage   = "10000"
  db_engine                  = "postgres"
  db_engine_version          = "12.18"
  rds_family                 = "postgres12"
  db_backup_retention_period = "7"
  db_name                    = "contact_moj_production"

  allow_major_version_upgrade = true
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "contact-moj_rds" {
  metadata {
    name      = "contact-moj-rds-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.contact-moj_rds.rds_instance_endpoint
    database_name         = module.contact-moj_rds.database_name
    database_username     = module.contact-moj_rds.database_username
    database_password     = module.contact-moj_rds.database_password
    rds_instance_address  = module.contact-moj_rds.rds_instance_address

    url = "postgres://${module.contact-moj_rds.database_username}:${module.contact-moj_rds.database_password}@${module.contact-moj_rds.rds_instance_endpoint}/${module.contact-moj_rds.database_name}"
  }
}
