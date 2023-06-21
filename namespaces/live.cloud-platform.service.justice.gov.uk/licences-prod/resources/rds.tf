module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "14.3"
  rds_family                  = "postgres14"
  db_password_rotated_date    = "13-04-2023"

  providers = {
    aws = aws.london
  }
}

resource "random_id" "probation_teams_password" {
  byte_length = 32
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint    = module.dps_rds.rds_instance_endpoint
    database_name            = module.dps_rds.database_name
    database_username        = module.dps_rds.database_username
    database_password        = module.dps_rds.database_password
    rds_instance_address     = module.dps_rds.rds_instance_address
    access_key_id            = module.dps_rds.access_key_id
    secret_access_key        = module.dps_rds.secret_access_key
    probation_teams_password = random_id.probation_teams_password.b64
  }
}
