module "manage_offences_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = var.rds_family
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  db_engine_version           = "14"

  db_password_rotated_date = "13-02-2023"

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
  }
}
