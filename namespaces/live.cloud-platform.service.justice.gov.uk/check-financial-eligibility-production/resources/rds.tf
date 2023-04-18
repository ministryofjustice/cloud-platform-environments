/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "check-financial-eligibility-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.17.1"

  vpc_name               = var.vpc_name
  team_name              = "apply-for-legal-aid"
  business-unit          = "laa"
  application            = "check-financial-eligibility"
  is-production          = "true"
  namespace              = var.namespace
  environment-name       = "production"
  infrastructure-support = "apply-for-civil-legal-aid@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "11"
  db_name                = "check_financial_eligibility_production"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  rds_family             = "postgres11"
  deletion_protection    = true

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
