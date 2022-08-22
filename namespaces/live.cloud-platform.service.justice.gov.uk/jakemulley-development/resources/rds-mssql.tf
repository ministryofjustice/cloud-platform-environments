/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/

module "rds_mssql" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.10"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  db_engine                   = "sqlserver-ex"
  db_engine_version           = "15.00.4198.2.v1"
  db_instance_class           = "db.t3.medium"
  db_allocated_storage        = 32
  rds_family                  = "sqlserver-ex-15.0"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false

  # Some engines can't apply some parameters without a reboot(ex SQL Server cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds_mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mssql.rds_instance_endpoint
    database_username     = module.rds_mssql.database_username
    database_password     = module.rds_mssql.database_password
    rds_instance_address  = module.rds_mssql.rds_instance_address
    access_key_id         = module.rds_mssql.access_key_id
    secret_access_key     = module.rds_mssql.secret_access_key
  }
}
