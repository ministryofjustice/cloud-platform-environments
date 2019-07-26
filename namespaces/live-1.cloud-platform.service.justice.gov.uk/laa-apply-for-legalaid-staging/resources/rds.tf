/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "apply-for-legal-aid-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "apply-for-legal-aid"
  business-unit          = "laa"
  application            = "laa-apply-for-legal-aid"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "apply@digtal.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "11.4"
  db_name                = "apply_for_legal_aid_staging"
  rds_family             = "postgres11"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "apply-for-legal-aid-rds" {
  metadata {
    name      = "apply-for-legal-aid-rds-instance-output"
    namespace = "laa-apply-for-legalaid-staging"
  }

  data {
    rds_instance_endpoint = "${module.apply-for-legal-aid-rds.rds_instance_endpoint}"
    database_name         = "${module.apply-for-legal-aid-rds.database_name}"
    database_username     = "${module.apply-for-legal-aid-rds.database_username}"
    database_password     = "${module.apply-for-legal-aid-rds.database_password}"
    rds_instance_address  = "${module.apply-for-legal-aid-rds.rds_instance_address}"

    url = "postgres://${module.apply-for-legal-aid-rds.database_username}:${module.apply-for-legal-aid-rds.database_password}@${module.apply-for-legal-aid-rds.rds_instance_endpoint}/${module.apply-for-legal-aid-rds.database_name}"
  }
}
