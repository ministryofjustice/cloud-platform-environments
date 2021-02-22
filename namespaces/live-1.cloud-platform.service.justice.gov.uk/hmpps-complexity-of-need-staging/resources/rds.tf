/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "complexity-of-need-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = "HMPPS"
  application            = "hmpps-complexity-of-need"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = "staging"
  infrastructure-support = "omic@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10"
  db_name                = "hmpps_complexity_of_need"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

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
    postgres_name     = module.complexity-of-need-rds.database_name
    postgres_host     = module.complexity-of-need-rds.rds_instance_address
    postgres_user     = module.complexity-of-need-rds.database_username
    postgres_password = module.complexity-of-need-rds.database_password
  }
}

