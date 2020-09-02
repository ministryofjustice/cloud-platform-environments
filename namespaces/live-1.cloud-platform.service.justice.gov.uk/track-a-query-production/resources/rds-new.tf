################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (new) (PostgreSQL)
#################################################################################

module "track_a_query_rds_new" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.6"
  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  team_name                  = "correspondence"
  business-unit              = "Central Digital"
  application                = "track-a-query"
  is-production              = "true"
  db_engine                  = "postgres"
  db_engine_version          = "9.5"
  db_backup_retention_period = "7"
  db_name                    = "track_a_query_production_new"
  environment-name           = "production"
  infrastructure-support     = "correspondence-support@digital.justice.gov.uk"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres9.5"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "track_a_query_rds_new" {
  metadata {
    name      = "track-a-query-rds-new-output"
    namespace = "track-a-query-production"
  }

  data = {
    rds_instance_endpoint = module.track_a_query_rds_new.rds_instance_endpoint
    database_name         = module.track_a_query_rds_new.database_name
    database_username     = module.track_a_query_rds_new.database_username
    database_password     = module.track_a_query_rds_new.database_password
    rds_instance_address  = module.track_a_query_rds_new.rds_instance_address

    access_key_id         = module.track_a_query_rds_new.access_key_id
    secret_access_key     = module.track_a_query_rds_new.secret_access_key

    url                   = "postgres://${module.track_a_query_rds_new.database_username}:${module.track_a_query_rds_new.database_password}@${module.track_a_query_rds_new.rds_instance_endpoint}/${module.track_a_query_rds_new.database_name}"
  }
}

