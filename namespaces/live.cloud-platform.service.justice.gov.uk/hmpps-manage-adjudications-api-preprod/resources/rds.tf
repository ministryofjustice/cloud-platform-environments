module "ma_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
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
  db_engine                   = "postgres"
  rds_family                  = "postgres15"
  db_password_rotated_date    = "15-02-2023"
  prepare_for_major_upgrade   = false
  db_allocated_storage        = 1000"

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

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "ma-rds-instance-output-preprod"
    namespace = "hmpps-manage-adjudications-api-prod"
  }

  data = {
    rds_instance_endpoint = module.ma_rds.rds_instance_endpoint
    database_name         = module.ma_rds.database_name
    database_username     = module.ma_rds.database_username
    database_password     = module.ma_rds.database_password
    rds_instance_address  = module.ma_rds.rds_instance_address
  }
}
