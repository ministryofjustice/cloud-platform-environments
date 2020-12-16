/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "crime_portal_mirror_gateway_rds" {
  source                       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name                 = var.cluster_name
  cluster_state_bucket         = var.cluster_state_bucket
  team_name                    = "probation-in-court"
  business-unit                = "hmpps"
  application                  = "crime-portal-mirror-gateway"
  is-production                = "false"
  namespace                    = var.namespace
  performance_insights_enabled = true
  environment-name             = "development"
  infrastructure-support       = "john.evans@digital.justice.gov.uk"
  rds_family                   = var.rds-family
  db_engine_version            = var.db_engine_version

  allow_major_version_upgrade = "true"
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "crime_portal_mirror_gateway_rds" {
  metadata {
    name      = "crime-portal-mirror-gateway-rds-instance-output"
    namespace = "crime-portal-mirror-gateway-dev"
  }

  data = {
    rds_instance_endpoint = module.crime_portal_mirror_gateway_rds.rds_instance_endpoint
    database_name         = module.crime_portal_mirror_gateway_rds.database_name
    database_username     = module.crime_portal_mirror_gateway_rds.database_username
    database_password     = module.crime_portal_mirror_gateway_rds.database_password
    rds_instance_address  = module.crime_portal_mirror_gateway_rds.rds_instance_address
    access_key_id         = module.crime_portal_mirror_gateway_rds.access_key_id
    secret_access_key     = module.crime_portal_mirror_gateway_rds.secret_access_key
    database_url          = "jdbc:postgresql://${module.crime_portal_mirror_gateway_rds.rds_instance_endpoint}/${module.crime_portal_mirror_gateway_rds.database_name}?ssl=true&sslmode=require"
  }
}


resource "kubernetes_secret" "crime_portal_mirror_gateway_rds_court_probation_dev" {
  metadata {
    name      = "crime-portal-mirror-gateway-rds-instance-output"
    namespace = "court-probation-dev"
  }

  data = {
    rds_instance_endpoint = module.crime_portal_mirror_gateway_rds.rds_instance_endpoint
    database_name         = module.crime_portal_mirror_gateway_rds.database_name
    database_username     = module.crime_portal_mirror_gateway_rds.database_username
    database_password     = module.crime_portal_mirror_gateway_rds.database_password
    rds_instance_address  = module.crime_portal_mirror_gateway_rds.rds_instance_address
    access_key_id         = module.crime_portal_mirror_gateway_rds.access_key_id
    secret_access_key     = module.crime_portal_mirror_gateway_rds.secret_access_key
    database_url          = "jdbc:postgresql://${module.crime_portal_mirror_gateway_rds.rds_instance_endpoint}/${module.crime_portal_mirror_gateway_rds.database_name}?ssl=true&sslmode=require"
  }
}
