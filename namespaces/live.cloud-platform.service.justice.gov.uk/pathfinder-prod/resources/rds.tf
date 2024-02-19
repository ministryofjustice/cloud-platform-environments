module "dps_rds" {
  source                   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                 = var.vpc_name
  team_name                = var.team_name
  business_unit            = var.business_unit
  application              = var.application
  is_production            = var.is_production
  namespace                = var.namespace
  db_instance_class        = "db.t4g.small"
  db_max_allocated_storage = "10000" # maximum storage for autoscaling
  db_engine_version        = "15.5"
  environment_name         = var.environment_name
  infrastructure_support   = var.infrastructure_support

  rds_family                = "postgres15"
  prepare_for_major_upgrade = false
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
