
variable "vpc_name" {
}


module "ma_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.16"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business-unit
  application                 = var.application
  is-production               = var.is-production
  namespace                   = var.namespace
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure-support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "14"
  rds_family                  = "postgres14"

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

