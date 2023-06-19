module "ma_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "14"
  rds_family                  = "postgres14"
  db_password_rotated_date    = "15-02-2023"

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
    access_key_id         = module.ma_rds.access_key_id
    secret_access_key     = module.ma_rds.secret_access_key
    url                   = "postgres://${module.ma_rds.database_username}:${module.ma_rds.database_password}@${module.ma_rds.rds_instance_endpoint}/${module.ma_rds.database_name}"
  }
}
