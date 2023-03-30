/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "allocation-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"

  vpc_name               = var.vpc_name
  team_name              = "offender-management"
  db_instance_class      = "db.m5.large"
  business-unit          = "HMPPS"
  application            = "offender-management-allocation-manager"
  is-production          = "true"
  namespace              = var.namespace
  environment-name       = "preprod"
  infrastructure-support = "omic@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "14"
  rds_family             = "postgres14"
  db_name                = "allocations"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "allocation-rds" {
  metadata {
    name      = "allocation-rds-instance-output"
    namespace = "offender-management-preprod"
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
