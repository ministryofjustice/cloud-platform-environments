#############################################
# Parliamentary Questions (postgres engine) #
#############################################

module "rds_instance" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  application                = var.application
  vpc_name                   = var.vpc_name
  environment_name           = var.environment-name
  infrastructure_support     = var.infrastructure_support
  is_production              = var.is_production
  namespace                  = var.namespace
  team_name                  = var.team_name
  business_unit              = "Central Digital"
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_name                    = "parliamentary_questions_dev"
  rds_family                 = "postgres12"
  db_backup_retention_period = var.db_backup_retention_period
  enable_rds_auto_start_stop = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds_instance" {
  metadata {
    name      = "parliamentary-questions-staging-rds"
    namespace = var.namespace
  }

  data = {
    database_name         = module.rds_instance.database_name
    database_password     = module.rds_instance.database_password
    database_username     = module.rds_instance.database_username
    rds_instance_address  = module.rds_instance.rds_instance_address
    rds_instance_endpoint = module.rds_instance.rds_instance_endpoint
    url                   = "postgres://${module.rds_instance.database_username}:${module.rds_instance.database_password}@${module.rds_instance.rds_instance_endpoint}/${module.rds_instance.database_name}"
  }
}
