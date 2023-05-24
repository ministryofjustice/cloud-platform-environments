module "identify_remand_periods_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment_name
  infrastructure-support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000" # maximum storage for autoscaling
  db_engine_version           = "15"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "identify_remand_periods_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.identify_remand_periods_rds.rds_instance_endpoint
    database_name         = module.identify_remand_periods_rds.database_name
    database_username     = module.identify_remand_periods_rds.database_username
    database_password     = module.identify_remand_periods_rds.database_password
    rds_instance_address  = module.identify_remand_periods_rds.rds_instance_address
    access_key_id         = module.identify_remand_periods_rds.access_key_id
    secret_access_key     = module.identify_remand_periods_rds.secret_access_key
  }
}
