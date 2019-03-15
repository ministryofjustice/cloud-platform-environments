/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "laa-get-paid"
  business-unit          = "legal-aid-agency"
  application            = "cccd"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  db_engine_version      = "10.6"
  db_name                = "adp_staging"
}

resource "kubernetes_secret" "cbo-rds-credentials-output" {
  metadata {
    name      = "cbo-rds-credentials-output"
    namespace = "cccd-staging"
  }

  data {
    rds_instance_endpoint = "${module.cbo-rds-credentials-output.rds_instance_endpoint}"
    database_name         = "${module.cbo-rds-credentials-output.database_name}"
    database_username     = "${module.cbo-rds-credentials-output.database_username}"
    database_password     = "${module.cbo-rds-credentials-output.database_password}"
    rds_instance_address  = "${module.cbo-rds-credentials-output.rds_instance_address}"
  }
}
