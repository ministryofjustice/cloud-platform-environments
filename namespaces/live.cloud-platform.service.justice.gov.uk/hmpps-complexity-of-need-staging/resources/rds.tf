/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "complexity-of-need-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=7.0.0"

  vpc_name                   = var.vpc_name
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  team_name                  = var.team_name
  business_unit              = "HMPPS"
  application                = "hmpps-complexity-of-need"
  is_production              = "false"
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = "manage-pom-cases@digital.justice.gov.uk"
  db_engine                  = "postgres"
  db_name                    = "hmpps_complexity_of_need"
  enable_rds_auto_start_stop = true

  db_engine_version           = "15.6"
  rds_family                  = "postgres15"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "complexity-of-need-rds" {
  metadata {
    name      = "hmpps-complexity-of-need-rds-instance-output"
    namespace = "hmpps-complexity-of-need-staging"
  }

  data = {
    rds_instance_endpoint = module.complexity-of-need-rds.rds_instance_endpoint
    postgres_name         = module.complexity-of-need-rds.database_name
    postgres_host         = module.complexity-of-need-rds.rds_instance_address
    postgres_user         = module.complexity-of-need-rds.database_username
    postgres_password     = module.complexity-of-need-rds.database_password
    rds_instance_address  = module.complexity-of-need-rds.rds_instance_address
  }
}
