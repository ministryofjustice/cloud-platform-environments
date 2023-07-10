/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "check-financial-eligibility-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"

  vpc_name                  = var.vpc_name
  team_name                 = "apply-for-legal-aid"
  business-unit             = "laa"
  application               = "check-financial-eligibility"
  is-production             = "true"
  namespace                 = var.namespace
  environment-name          = "production"
  infrastructure-support    = "apply-for-civil-legal-aid@digital.justice.gov.uk"
  db_engine                 = "postgres"

  # specified as latest version that can be upgraded from 11.16
  db_engine_version         = "14.7"

  db_name                   = "check_financial_eligibility_production"
  db_parameter              = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  rds_family                = "postgres14"
  deletion_protection       = true
  db_instance_class         = "db.t4g.small"
  db_max_allocated_storage  = "500"
  allow_minor_version_upgrade = "false"
  prepare_for_major_upgrade = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "check-financial-eligibility-rds" {
  metadata {
    name      = "check-financial-eligibility-rds-instance-output"
    namespace = "check-financial-eligibility-production"
  }

  data = {
    rds_instance_endpoint = module.check-financial-eligibility-rds.rds_instance_endpoint
    database_name         = module.check-financial-eligibility-rds.database_name
    database_username     = module.check-financial-eligibility-rds.database_username
    database_password     = module.check-financial-eligibility-rds.database_password
    rds_instance_address  = module.check-financial-eligibility-rds.rds_instance_address
  }
}
