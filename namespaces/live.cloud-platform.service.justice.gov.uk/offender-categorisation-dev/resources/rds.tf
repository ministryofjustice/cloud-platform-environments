module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  rds_family                  = var.rds-family
  db_instance_class           = "db.t3.small"
  db_engine_version           = "14"
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
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
    access_key_id          = module.dps_rds.access_key_id
    secret_access_key      = module.dps_rds.secret_access_key
    risk_profiler_password = random_id.risk_profiler_role_password.b64
  }
}
