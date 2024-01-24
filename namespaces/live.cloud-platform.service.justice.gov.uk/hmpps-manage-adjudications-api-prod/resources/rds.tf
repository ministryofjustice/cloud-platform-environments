module "ma_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "15"
  rds_family                  = "postgres15"
  db_password_rotated_date    = "15-02-2023"
  allow_minor_version_upgrade = "true"
  db_engine                   = "postgres"
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  deletion_protection         = true
  prepare_for_major_upgrade   = false
  db_allocated_storage        = "1500"


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "ma-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.ma_rds.rds_instance_endpoint
    database_name         = module.ma_rds.database_name
    database_username     = module.ma_rds.database_username
    database_password     = module.ma_rds.database_password
    rds_instance_address  = module.ma_rds.rds_instance_address
    url                   = "postgres://${module.ma_rds.database_username}:${module.ma_rds.database_password}@${module.ma_rds.rds_instance_endpoint}/${module.ma_rds.database_name}"
  }
}
