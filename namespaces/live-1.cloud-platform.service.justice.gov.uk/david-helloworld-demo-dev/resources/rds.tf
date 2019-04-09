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
module "multi_container_demo_app_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.0"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "cloud-platform"
  business-unit          = "cloud-platform"
  application            = "multi-container-demo-app"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "david.salgado@digtal.justice.gov.uk"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "multi_container_demo_rds" {
  metadata {
    name      = "multi-container-demo-rds"
    namespace = "david-helloworld-demo-dev"
  }

  data {
    url = "postgres://${module.multi_container_demo_app_rds.database_username}:${module.multi_container_demo_app_rds.database_password}@${module.multi_container_demo_app_rds.rds_instance_endpoint}/${module.multi_container_demo_app_rds.database_name}"
  }
}
