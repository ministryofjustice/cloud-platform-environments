module "dps_rds" {

  source                        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                      = var.vpc_name
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  namespace                     = var.namespace
  environment_name              = var.environment-name
  infrastructure_support        = var.infrastructure_support
  db_instance_class             = "db.t4g.micro"
  db_max_allocated_storage      = "500"
  deletion_protection           = true
  prepare_for_major_upgrade     = false
  rds_family                    = "postgres16"
  db_engine                     = "postgres"
  db_engine_version             = "16"
  performance_insights_enabled  = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}
