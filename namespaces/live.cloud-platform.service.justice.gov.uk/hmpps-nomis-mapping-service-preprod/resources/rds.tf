module "dps_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure_support
  rds_family                  = var.rds-family
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t3.small"
  db_engine_version           = "14"
  db_password_rotated_date    = "2023-02-21"
  deletion_protection         = true

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
    access_key_id         = module.dps_rds.access_key_id
    secret_access_key     = module.dps_rds.secret_access_key
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "dps-rds-instance-output-preprod"
    namespace = "hmpps-nomis-mapping-service-prod"
  }

  data = {
    database_name        = module.dps_rds.database_name
    database_username    = module.dps_rds.database_username
    database_password    = module.dps_rds.database_password
    rds_instance_address = module.dps_rds.rds_instance_address
  }
}

