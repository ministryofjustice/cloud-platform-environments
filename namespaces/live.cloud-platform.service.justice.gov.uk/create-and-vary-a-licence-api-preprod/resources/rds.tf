module "create_and_vary_a_licence_api_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.1.0"
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = var.application
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false
  enable_rds_auto_start_stop  = true
  db_instance_class           = "db.t4g.small"
  db_engine_version           = "17.5"
  rds_family                  = "postgres17"
  db_password_rotated_date    = "25-09-2024"
  db_allocated_storage        = 50
  performance_insights_enabled = true

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

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "rds_refresh_creds" {
  metadata {
    name      = "rds-instance-output-preprod"
    namespace = "create-and-vary-a-licence-api-prod"
  }

  data = {
    database_name        = module.create_and_vary_a_licence_api_rds.database_name
    database_username    = module.create_and_vary_a_licence_api_rds.database_username
    database_password    = module.create_and_vary_a_licence_api_rds.database_password
    rds_instance_address = module.create_and_vary_a_licence_api_rds.rds_instance_address
  }
}
