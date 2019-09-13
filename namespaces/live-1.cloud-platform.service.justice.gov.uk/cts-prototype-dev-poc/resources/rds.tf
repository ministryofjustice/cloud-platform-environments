################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (PostgreSQL)
#################################################################################

module "track_a_query_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.6"
  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  team_name                  = "correspondence"
  business-unit              = "Central Digital"
  application                = "track-a-query"
  is-production              = "false"
  db_engine                  = "postgres"
  db_engine_version          = "9.5"
  db_backup_retention_period = "7"
  db_name                    = "track_a_query_poc"
  environment-name           = "development"
  infrastructure-support     = "mohammed.seedat@digtal.justice.gov.uk"

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres9.5"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  apply_method = "pending-reboot"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "track_a_query_rds" {
  metadata {
    name      = "track-a-query-rds-output"
    namespace = "cts-prototype-dev-poc"
  }

  data {
    rds_instance_endpoint = "${module.track_a_query_rds.rds_instance_endpoint}"
    database_name         = "${module.track_a_query_rds.database_name}"
    database_username     = "${module.track_a_query_rds.database_username}"
    database_password     = "${module.track_a_query_rds.database_password}"
    rds_instance_address  = "${module.track_a_query_rds.rds_instance_address}"
    url                   = "postgres://${module.track_a_query_rds.database_username}:${module.track_a_query_rds.database_password}@${module.track_a_query_rds.rds_instance_endpoint}/${module.track_a_query_rds.database_name}"
  }
}
