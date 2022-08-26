/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

# IMP NOTE: Updating to module version 5.3, existing database password will be rotated.
# Make sure you restart your pods which use this RDS secret to avoid any down time.

module "cla_backend_rds_postgres_10" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.11"
  cluster_name  = var.cluster_name
  team_name     = var.team_name
  business-unit = var.business-unit
  application   = var.application
  is-production = var.is-production
  namespace     = var.namespace

  db_name = "cla_backend"
  # change the postgres version as you see fit.
  db_engine_version      = "10"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres10"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".


  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  snapshot_identifier = "cla-backend-manual-snapshot-2022-08-01"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}


resource "kubernetes_secret" "cla_backend_rds_postgres_10" {
  metadata {
    name      = "database-10"
    namespace = var.namespace
  }

  data = {
    endpoint          = module.cla_backend_rds_postgres_10.rds_instance_endpoint
    host              = module.cla_backend_rds_postgres_10.rds_instance_address
    port              = module.cla_backend_rds_postgres_10.rds_instance_port
    name              = module.cla_backend_rds_postgres_10.database_name
    user              = module.cla_backend_rds_postgres_10.database_username
    password          = module.cla_backend_rds_postgres_10.database_password
    db_identifier     = module.cla_backend_rds_postgres_10.db_identifier
    access_key_id     = module.cla_backend_rds_postgres_10.access_key_id
    secret_access_key = module.cla_backend_rds_postgres_10.secret_access_key
  }

}
