module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment_name
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds-family
  db_instance_class           = "db.t3.medium"
  db_engine_version           = "14"
  allow_major_version_upgrade = "false"
  performance_insights_enabled = "true"
}

resource "random_id" "risk_profiler_role_password" {
  byte_length = 32
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint  = module.dps_rds.rds_instance_endpoint
    database_name          = module.dps_rds.database_name
    database_username      = module.dps_rds.database_username
    database_password      = module.dps_rds.database_password
    rds_instance_address   = module.dps_rds.rds_instance_address
    risk_profiler_password = random_id.risk_profiler_role_password.b64_url
  }
}
