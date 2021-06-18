################################################################################
# Track a Query (Correspondence Tool Staff)
# Application RDS (PostgreSQL)
#################################################################################

module "metabase_rds" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.3"
  cluster_name               = var.cluster_name
  team_name                  = "correspondence"
  business-unit              = "Central Digital"
  application                = "track-a-query-metabase"
  is-production              = "true"
  namespace                  = var.namespace
  db_engine                  = "postgres"
  db_engine_version          = "12"
  db_backup_retention_period = "7"
  db_name                    = "metabase_production"
  environment-name           = "production"
  infrastructure-support     = "correspondence-support@digital.justice.gov.uk"

  rds_family = "postgres12"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "metabase_rds" {
  metadata {
    name      = "metabase-rds-output"
    namespace = "metabase-production"
  }

  data = {
    rds_instance_endpoint = module.metabase_rds.rds_instance_endpoint
    database_name         = module.metabase_rds.database_name
    database_username     = module.metabase_rds.database_username
    database_password     = module.metabase_rds.database_password
    rds_instance_address  = module.metabase_rds.rds_instance_address

    access_key_id     = module.metabase_rds.access_key_id
    secret_access_key = module.metabase_rds.secret_access_key

    url = "postgres://${module.metabase_rds.database_username}:${module.metabase_rds.database_password}@${module.metabase_rds.rds_instance_endpoint}/${module.metabase_rds.database_name}"
  }
}

