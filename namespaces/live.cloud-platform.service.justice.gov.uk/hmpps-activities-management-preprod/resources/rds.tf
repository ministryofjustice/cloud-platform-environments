module "activities_api_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
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
  db_instance_class           = "db.t3.small"
  db_engine_version           = "14"


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "activities_api_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.activities_api_rds.rds_instance_endpoint
    database_name         = module.activities_api_rds.database_name
    database_username     = module.activities_api_rds.database_username
    database_password     = module.activities_api_rds.database_password
    rds_instance_address  = module.activities_api_rds.rds_instance_address
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "rds_refresh_creds" {
  metadata {
    name      = "rds-instance-output-preprod"
    namespace = "hmpps-activities-management-prod"
  }

  data = {
    database_name        = module.activities_api_rds.database_name
    database_username    = module.activities_api_rds.database_username
    database_password    = module.activities_api_rds.database_password
    rds_instance_address = module.activities_api_rds.rds_instance_address
  }
}
