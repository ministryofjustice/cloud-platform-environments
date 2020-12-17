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
module "allocation-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  db_instance_class      = "db.m4.large"
  team_name              = "offender-management"
  business-unit          = "HMPPS"
  application            = "offender-management-allocation-manager"
  is-production          = "true"
  namespace              = var.namespace
  environment-name       = "production"
  infrastructure-support = "omic@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10"
  db_name                = "allocations"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

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

