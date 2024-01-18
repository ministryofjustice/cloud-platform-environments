/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "prison-visits-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                 = var.vpc_name
  team_name                = "prison-visits-booking"
  db_instance_class        = "db.m5.xlarge"
  db_allocated_storage     = "50"
  business_unit            = "HMPPS"
  application              = "prison-visits-booking-production"
  is_production            = var.is_production
  namespace                = var.namespace
  environment_name         = "production"
  infrastructure_support   = "pvb-technical-support@digital.justice.gov.uk"
  db_engine                = "postgres"
  db_engine_version        = "12.11"
  db_name                  = "visits"
  db_parameter             = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  rds_family               = "postgres12"
  db_password_rotated_date = "2023-05-11"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_minor_version_upgrade  = "false"
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison-visits-rds" {
  metadata {
    name      = "prison-visits-rds-instance-output"
    namespace = "prison-visits-booking-production"
  }

  data = {
    url = "postgres://${module.prison-visits-rds.database_username}:${module.prison-visits-rds.database_password}@${module.prison-visits-rds.rds_instance_endpoint}/${module.prison-visits-rds.database_name}"
  }
}
