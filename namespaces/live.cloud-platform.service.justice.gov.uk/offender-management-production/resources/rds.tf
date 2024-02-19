/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "allocation-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"

  vpc_name                    = var.vpc_name
  db_instance_class           = "db.m5.large"
  team_name                   = "offender-management"
  business_unit               = "HMPPS"
  application                 = "offender-management-allocation-manager"
  is_production               = "true"
  namespace                   = var.namespace
  environment_name            = "production"
  infrastructure_support      = "manage-pom-cases@digital.justice.gov.uk"
  db_engine                   = "postgres"
  db_engine_version           = "14.7"
  rds_family                  = "postgres14"
  allow_minor_version_upgrade = "false"
  db_name                     = "allocations"
  db_parameter                = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

  db_password_rotated_date = "2023-04-05T11:31:27Z"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "allocation-rds" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = "offender-management-production"
  }

  data = {
    rds_instance_endpoint = module.allocation-rds.rds_instance_endpoint
    rds_instance_address  = module.allocation-rds.rds_instance_address
    database_name         = module.allocation-rds.database_name
    database_username     = module.allocation-rds.database_username
    database_password     = module.allocation-rds.database_password
    postgres_name         = module.allocation-rds.database_name
    postgres_host         = module.allocation-rds.rds_instance_address
    postgres_user         = module.allocation-rds.database_username
    postgres_password     = module.allocation-rds.database_password
  }
}
