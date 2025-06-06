################################################################################
# contact-moj
# Application RDS (PostgreSQL)
#################################################################################

module "contact-moj_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  db_allocated_storage       = 10
  storage_type               = "gp2"
  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  db_engine                  = "postgres"
  db_engine_version          = "16"
  rds_family                 = "postgres16"
  db_backup_retention_period = "7"
  db_name                    = "contact_moj_staging"
  enable_rds_auto_start_stop = true
  backup_window              = "06:00-08:00"

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
