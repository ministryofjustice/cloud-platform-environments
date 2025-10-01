module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment_name
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds-family
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000"
  db_engine_version           = "17"
  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = false
  enable_rds_auto_start_stop  = true
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

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "dps-rds-instance-output-preprod"
    namespace = "offender-categorisation-prod"
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
