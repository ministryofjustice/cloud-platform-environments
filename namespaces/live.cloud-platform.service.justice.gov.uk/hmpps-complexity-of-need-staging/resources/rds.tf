/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "complexity-of-need-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name               = var.vpc_name
  db_instance_class      = "db.t3.small"
  team_name              = var.team_name
  business-unit          = "HMPPS"
  application            = "hmpps-complexity-of-need"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = "manage-pom-cases@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "14"
  rds_family             = "postgres14"
  db_name                = "hmpps_complexity_of_need"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

  allow_major_version_upgrade = true

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
    access_key_id         = module.complexity-of-need-rds.access_key_id
    secret_access_key     = module.complexity-of-need-rds.secret_access_key
  }
}
