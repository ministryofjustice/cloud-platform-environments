/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "check-financial-eligibility-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.2"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "apply-for-legal-aid"
  business-unit          = "laa"
  application            = "check-financial-eligibility"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "apply@digtal.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "11.2"
  db_name                = "check_financial_eligibility_staging"
}

resource "kubernetes_secret" "check-financial-eligibility-rds" {
  metadata {
    name      = "check-financial-eligibility-rds-instance-output"
    namespace = "check-financial-eligibility-staging"
  }

  data {
    rds_instance_endpoint = "${module.check-financial-eligibility-rds.rds_instance_endpoint}"
    database_name         = "${module.check-financial-eligibility-rds.database_name}"
    database_username     = "${module.check-financial-eligibility-rds.database_username}"
    database_password     = "${module.check-financial-eligibility-rds.database_password}"
    rds_instance_address  = "${module.check-financial-eligibility-rds.rds_instance_address}"
  }
}
