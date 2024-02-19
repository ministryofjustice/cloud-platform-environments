/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

# IMP NOTE: Updating to module version 5.3, existing database password will be rotated.
# Make sure you restart your pods which use this RDS secret to avoid any down time.

module "cla_backend_rds_postgres_14" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  db_name = "cla_backend"
  # change the postgres version as you see fit.
  db_engine_version      = "14"
  db_instance_class      = "db.t4g.small"
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

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

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

module "cla_backend_cfe_integration_rds_postgres_14" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  db_name = "cla_backend"
  # change the postgres version as you see fit.
  db_engine_version      = "14"
  db_instance_class      = "db.t4g.small"
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

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

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

module "cla_backend_metabase_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name      = var.vpc_name
  team_name     = var.team_name
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  namespace     = var.namespace

  db_name                  = "metabase"
  db_engine_version        = "15"
  db_instance_class        = "db.t4g.micro"
  db_allocated_storage     = "5"
  db_max_allocated_storage = "500"
  environment_name         = var.environment-name
  infrastructure_support   = var.infrastructure_support

  rds_family = "postgres15"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cla_backend_rds_postgres_14" {
  metadata {
    name      = "database-14"
    namespace = var.namespace
  }

  data = {
    endpoint      = module.cla_backend_rds_postgres_14.rds_instance_endpoint
    host          = module.cla_backend_rds_postgres_14.rds_instance_address
    port          = module.cla_backend_rds_postgres_14.rds_instance_port
    name          = module.cla_backend_rds_postgres_14.database_name
    user          = module.cla_backend_rds_postgres_14.database_username
    password      = module.cla_backend_rds_postgres_14.database_password
    db_identifier = module.cla_backend_rds_postgres_14.db_identifier
  }
}
resource "kubernetes_secret" "cla_backend_metabase_rds" {
  metadata {
    name      = "metabase"
    namespace = var.namespace
  }

  data = {
    endpoint      = module.cla_backend_metabase_rds.rds_instance_endpoint
    host          = module.cla_backend_metabase_rds.rds_instance_address
    port          = module.cla_backend_metabase_rds.rds_instance_port
    name          = module.cla_backend_metabase_rds.database_name
    user          = module.cla_backend_metabase_rds.database_username
    password      = module.cla_backend_metabase_rds.database_password
    db_identifier = module.cla_backend_metabase_rds.db_identifier

    # postgres://user:password@host:port/name
    url = "postgres://${module.cla_backend_metabase_rds.database_username}:${module.cla_backend_metabase_rds.database_password}@${module.cla_backend_metabase_rds.rds_instance_endpoint}/${module.cla_backend_metabase_rds.database_name}"

    # jdbc:postgresql://host:port/name?user=user&password=password
    jdbc_url = "jdbc:postgresql://${module.cla_backend_metabase_rds.rds_instance_endpoint}/${module.cla_backend_metabase_rds.database_name}?user=${module.cla_backend_metabase_rds.database_username}&password=${module.cla_backend_metabase_rds.database_password}"
  }
}

resource "kubernetes_secret" "cla_backend_cfe_integration_rds_postgres_14" {
  metadata {
    name      = "eligibility-integration-database-14"
    namespace = var.namespace
  }

  data = {
    endpoint      = module.cla_backend_cfe_integration_rds_postgres_14.rds_instance_endpoint
    host          = module.cla_backend_cfe_integration_rds_postgres_14.rds_instance_address
    port          = module.cla_backend_cfe_integration_rds_postgres_14.rds_instance_port
    name          = module.cla_backend_cfe_integration_rds_postgres_14.database_name
    user          = module.cla_backend_cfe_integration_rds_postgres_14.database_username
    password      = module.cla_backend_cfe_integration_rds_postgres_14.database_password
    db_identifier = module.cla_backend_cfe_integration_rds_postgres_14.db_identifier
  }

}