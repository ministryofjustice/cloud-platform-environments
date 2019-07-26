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
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.3"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "prison-visits-booking"
  db_instance_class      = "db.m4.large"
  business-unit          = "HMPPS"
  application            = "prison-visits-booking-production"
  is-production          = "${var.is-production}"
  environment-name       = "production"
  infrastructure-support = "pvb-technical-support@digtal.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "9.6"
  db_name                = "visits"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "prison-visits-rds" {
  metadata {
    name      = "prison-visits-rds-instance-output"
    namespace = "prison-visits-booking-production"
  }

  data {
    url = "postgres://${module.prison-visits-rds.database_username}:${module.prison-visits-rds.database_password}@${module.prison-visits-rds.rds_instance_endpoint}/${module.prison-visits-rds.database_name}"
  }
}
