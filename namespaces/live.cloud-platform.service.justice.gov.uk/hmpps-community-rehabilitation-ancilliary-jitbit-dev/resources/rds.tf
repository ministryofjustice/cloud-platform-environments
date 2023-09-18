/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # If the rds_name is not specified a random name will be generated ( cp-* )
  # Changing the RDS name requires the RDS to be re-created (destroy + create)
  # rds_name             = "my-rds-name"

  # Engine options
  db_engine         = "sqlserver-ex"
  db_engine_version = "15.00.4073.23.v1" # SQL Server 2019
  license_model     = "license-included"

  # change the instance class as you see fit.
  db_instance_class = "db.t3.medium" # 2 vCPU, 4 GiB

  rds_family = "sqlserver-ex-15.0"

  # Storage values
  db_allocated_storage     = "50"
  db_max_allocated_storage = "50"

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "0"
      apply_method = "pending-reboot"
    }
  ]

  allow_minor_version_upgrade = "false"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # Enable auto start and stop of the RDS instances during 10:00 PM - 6:00 AM for cost saving, recommended for non-prod instances
  # enable_rds_auto_start_stop  = true

  # set performance insights to off
  performance_insights_enabled = false

  enable_rds_auto_start_stop = true

  # This will rotate the db password. Update the value to the current date.
  db_password_rotated_date = "08-03-2023"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}


resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-mssql-instance-output"
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
  }
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier

  }
}
