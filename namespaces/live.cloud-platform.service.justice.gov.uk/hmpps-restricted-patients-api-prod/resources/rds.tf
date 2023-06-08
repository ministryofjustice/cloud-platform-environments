module "rp_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name                  = var.vpc_name
  team_name                 = var.team_name
  business-unit             = var.business_unit
  application               = var.application
  is-production             = var.is_production
  namespace                 = var.namespace
  environment-name          = var.environment
  infrastructure-support    = var.infrastructure_support
  db_instance_class         = "db.t4g.small"
  db_engine                 = "postgres"
  db_engine_version         = "15"
  rds_family                = "postgres15"
  db_password_rotated_date  = "15-02-2023"
  deletion_protection       = true
  prepare_for_major_upgrade = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "rp-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rp_rds.rds_instance_endpoint
    database_name         = module.rp_rds.database_name
    database_username     = module.rp_rds.database_username
    database_password     = module.rp_rds.database_password
    rds_instance_address  = module.rp_rds.rds_instance_address
    access_key_id         = module.rp_rds.access_key_id
    secret_access_key     = module.rp_rds.secret_access_key
    url                   = "postgres://${module.rp_rds.database_username}:${module.rp_rds.database_password}@${module.rp_rds.rds_instance_endpoint}/${module.rp_rds.database_name}"
  }
}

