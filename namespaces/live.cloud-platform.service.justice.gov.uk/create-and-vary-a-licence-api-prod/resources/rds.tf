module "create_and_vary_a_licence_api_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_minor_version_upgrade = "false"
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "14.7"
  rds_family                  = "postgres14"
  db_password_rotated_date    = "13-04-2023"
  db_allocated_storage        = 20

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "create_and_vary_a_licence_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.create_and_vary_a_licence_api_rds.rds_instance_endpoint
    database_name         = module.create_and_vary_a_licence_api_rds.database_name
    database_username     = module.create_and_vary_a_licence_api_rds.database_username
    database_password     = module.create_and_vary_a_licence_api_rds.database_password
    rds_instance_address  = module.create_and_vary_a_licence_api_rds.rds_instance_address
  }
}
