/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "prison-visits-rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.1.0"
  storage_type           = "gp2"
  vpc_name               = var.vpc_name
  team_name              = "prison-visits-booking"
  business_unit          = "HMPPS"
  application            = "prison-visits-booking-production"
  is_production          = var.is_production
  environment_name       = "production"
  infrastructure_support = "pvb-technical-support@digital.justice.gov.uk"
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version = "15.12"
  rds_family                  = "postgres15"

  db_instance_class        = "db.m5.xlarge"
  db_allocated_storage     = "50"
  db_name                  = "visits"
  db_parameter             = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  db_password_rotated_date = "2023-05-11"

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
