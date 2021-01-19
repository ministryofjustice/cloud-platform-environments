################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (PostgreSQL)
#################################################################################

module "track_a_query_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  team_name                  = "correspondence"
  business-unit              = "Central Digital"
  application                = "track-a-query"
  is-production              = "false"
  namespace                  = var.namespace
  db_engine                  = "postgres"
  db_engine_version          = "12.3"
  db_backup_retention_period = "7"
  db_name                    = "track_a_query_staging"
  environment-name           = "staging"
  infrastructure-support     = "correspondence-support@digital.justice.gov.uk"

  rds_family = "postgres12"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".


  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "track_a_query_rds" {
  metadata {
    name      = "track-a-query-rds-output"
    namespace = "track-a-query-staging"
  }

  data = {
    rds_instance_endpoint = module.track_a_query_rds.rds_instance_endpoint
    database_name         = module.track_a_query_rds.database_name
    database_username     = module.track_a_query_rds.database_username
    database_password     = module.track_a_query_rds.database_password
    rds_instance_address  = module.track_a_query_rds.rds_instance_address

    access_key_id     = module.track_a_query_rds.access_key_id
    secret_access_key = module.track_a_query_rds.secret_access_key

    url = "postgres://${module.track_a_query_rds.database_username}:${module.track_a_query_rds.database_password}@${module.track_a_query_rds.rds_instance_endpoint}/${module.track_a_query_rds.database_name}"
  }
}

