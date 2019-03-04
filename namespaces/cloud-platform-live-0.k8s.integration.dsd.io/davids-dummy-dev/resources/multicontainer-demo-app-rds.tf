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
module "multi_container_demo_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  application            = "${var.application}"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
}

resource "kubernetes_secret" "multi_container_demo_rds" {
  metadata {
    name      = "rds-instance-${var.application}-${var.environment-name}"
    namespace = "${var.namespace}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.multi_container_demo_rds.database_username}:${module.multi_container_demo_rds.database_password}@${module.multi_container_demo_rds.rds_instance_endpoint}/${module.multi_container_demo_rds.database_name}"
  }
}
