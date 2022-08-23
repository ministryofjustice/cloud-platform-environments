/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "allocation-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.10"

  cluster_name           = var.cluster_name
  db_instance_class      = "db.t3.small"
  team_name              = "offender-management"
  business-unit          = "HMPPS"
  application            = "offender-management-allocation-manager"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = "staging"
  infrastructure-support = "omic@digital.justice.gov.uk"
  db_engine              = "postgres"
  rds_family             = "postgres14"
  db_engine_version      = "14.3"
  db_name                = "allocations"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

  allow_major_version_upgrade = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "allocation-rds" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = "offender-management-staging"
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
    access_key_id         = module.allocation-rds.access_key_id
    secret_access_key     = module.allocation-rds.secret_access_key
  }
}

resource "kubernetes_secret" "allocation-rds-test" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = "offender-management-test"
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
