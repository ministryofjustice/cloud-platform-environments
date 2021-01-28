/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "nomis-delius-emulator-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = "HMPPS"
  application            = "nomis-delius-emulator"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = "staging"
  infrastructure-support = "omic@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10"
  db_name                = "nomis_delius_emulator"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "nomis-delius-emulator-rds" {
  metadata {
    name      = "nomis-delius-emulator-rds-instance"
    namespace = "offender-management-staging"
  }

  data = {
    postgres_name     = module.nomis-delius-emulator-rds.database_name
    postgres_host     = module.nomis-delius-emulator-rds.rds_instance_address
    postgres_user     = module.nomis-delius-emulator-rds.database_username
    postgres_password = module.nomis-delius-emulator-rds.database_password
  }
}

