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
module "prison-visits-booking-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "prison-visits-booking"
  business-unit          = "HMPPS"
  application            = "prison-visits-booking"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "pvb-technical-support@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "10.5"
  db_name                = "prisonvisitsbooking"
}

resource "kubernetes_secret" "prison-visits-booking-rds" {
  metadata {
    name      = "prison-visits-booking-rds-instance-output"
    namespace = "prison-visits-booking-staging"
  }

  data {
    rds_instance_endpoint = "${module.prison-visits-booking-rds.rds_instance_endpoint}"
    rds_instance_address  = "${module.prison-visits-booking-rds.rds_instance_address}"
    database_name         = "${module.prison-visits-booking-rds.database_name}"
    database_username     = "${module.prison-visits-booking-rds.database_username}"
    database_password     = "${module.prison-visits-booking-rds.database_password}"
    postgres_name         = "${module.prison-visits-booking-rds.database_name}"
    postgres_host         = "${module.prison-visits-booking-rds.rds_instance_address}"
    postgres_user         = "${module.prison-visits-booking-rds.database_username}"
    postgres_password     = "${module.prison-visits-booking-rds.database_password}"
  }
}
