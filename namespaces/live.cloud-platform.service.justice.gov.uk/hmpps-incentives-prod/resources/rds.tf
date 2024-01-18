module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  prepare_for_major_upgrade   = false
  db_instance_class           = "db.t4g.large"
  rds_family                  = "postgres15"
  db_engine_version           = "15"
  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"

  backup_window       = var.backup_window
  maintenance_window  = var.maintenance_window
  deletion_protection = true

  db_password_rotated_date = "07-02-2023"

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
    db_identifier         = module.dps_rds.db_identifier
    resource_id           = module.dps_rds.resource_id
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}
