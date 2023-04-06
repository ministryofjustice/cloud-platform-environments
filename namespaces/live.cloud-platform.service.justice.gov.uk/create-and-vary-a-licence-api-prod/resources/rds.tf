module "create_and_vary_a_licence_api_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = var.application
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  allow_major_version_upgrade = "true"
  db_instance_class           = "db.t3.large"
  db_engine_version           = "14.3"
  rds_family                  = "postgres14"

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
    access_key_id         = module.create_and_vary_a_licence_api_rds.access_key_id
    secret_access_key     = module.create_and_vary_a_licence_api_rds.secret_access_key
  }
}

