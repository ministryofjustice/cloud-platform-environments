/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {}

variable "cluster_state_bucket" {}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "prison-visits-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.0"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "prison-visits-booking"
  business-unit          = "HMPPS"
  application            = "prison-visits-booking-staging"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "pvb-technical-support@digtal.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "9.4"
  db_name                = "visits"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "prison-visits-rds" {
  metadata {
    name      = "prison-visits-rds-instance-output"
    namespace = "prison-visits-booking-staging"
  }

  data {
    rds_instance_endpoint = "${module.prison-visits.rds_instance_endpoint}"
    rds_instance_address  = "${module.prison-visits.rds_instance_address}"
    database_name         = "${module.prison-visits.database_name}"
    database_username     = "${module.prison-visits.database_username}"
    database_password     = "${module.prison-visits.database_password}"
    postgres_name         = "${module.prison-visits.database_name}"
    postgres_host         = "${module.prison-visits.rds_instance_address}"
    postgres_user         = "${module.prison-visits.database_username}"
    postgres_password     = "${module.prison-visits.database_password}"
  }
}
