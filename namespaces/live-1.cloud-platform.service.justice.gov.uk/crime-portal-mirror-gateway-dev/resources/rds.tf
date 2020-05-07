/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

# IMP NOTE: Updating to module version 5.3, existing database password will be rotated.
# Make sure you restart your pods which use this RDS secret to avoid any down time.

module "crime_portal_mirror_gateway_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.3"
  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket
  team_name            = "probation-in-court"
  business-unit        = "hmpps"
  application          = "crime-portal-mirror-gateway"
  is-production        = "false"

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version      = "10"
  environment-name       = "development"
  infrastructure-support = "john.evans@digital.justice.gov.uk"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres10"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  apply_method = "pending-reboot"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
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
    database_url = "postgres://${module.crime_portal_mirror_gateway_rds.rds_instance_endpoint}/${module.crime_portal_mirror_gateway_rds.database_name}"
  }
}