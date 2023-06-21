module "manage_offences_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t3.small"
  db_engine_version           = "14"

  db_password_rotated_date = "14-02-2023"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "manage_offences_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.manage_offences_rds.rds_instance_endpoint
    database_name         = module.manage_offences_rds.database_name
    database_username     = module.manage_offences_rds.database_username
    database_password     = module.manage_offences_rds.database_password
    rds_instance_address  = module.manage_offences_rds.rds_instance_address
    access_key_id         = module.manage_offences_rds.access_key_id
    secret_access_key     = module.manage_offences_rds.secret_access_key
  }
}
