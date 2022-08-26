/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "rds" {

  # Meta
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.11"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # Postgres
  rds_name                     = "${var.app_short_name}-${var.environment}"
  performance_insights_enabled = true
  db_engine_version            = "13"
  db_instance_class            = "db.t3.small" # TODO: Is this big enough?
  rds_family                   = "postgres13"
  allow_major_version_upgrade  = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "postgres-secrets"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
    # Backstage stuff 
    POSTGRES_USER     = module.rds.database_username
    POSTGRES_PASSWORD = module.rds.database_password
    POSTGRES_PORT     = module.rds.rds_instance_port
    POSTGRES_HOST     = module.rds.rds_instance_address

  }
}
