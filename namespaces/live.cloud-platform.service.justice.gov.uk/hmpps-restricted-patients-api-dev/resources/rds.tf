module "rp_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name                   = var.vpc_name
  team_name                  = var.team_name
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  db_instance_class          = "db.t4g.small"
  db_engine                  = "postgres"
  db_engine_version          = "17"
  rds_family                 = "postgres17"
  db_password_rotated_date   = "15-02-2023"
  deletion_protection        = true
  prepare_for_major_upgrade  = false
  enable_rds_auto_start_stop = true

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "rp-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rp_rds.rds_instance_endpoint
    database_name         = module.rp_rds.database_name
    database_username     = module.rp_rds.database_username
    database_password     = module.rp_rds.database_password
    rds_instance_address  = module.rp_rds.rds_instance_address
    url                   = "postgres://${module.rp_rds.database_username}:${module.rp_rds.database_password}@${module.rp_rds.rds_instance_endpoint}/${module.rp_rds.database_name}"
  }
}
