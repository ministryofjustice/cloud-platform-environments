variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "becca_test_app_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.0"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "tactical-products"
  business-unit          = "central-digital"
  application            = "becca-test-app"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "my-app-never-fails@digtal.justice.gov.uk"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "becca_test_app_rds" {
  metadata {
    name      = "becca-test-app-rds-instance-output"
    namespace = "becca-test-app-dev"
  }

  data {
    url = "postgres://${module.becca_test_app_rds.database_username}:${module.becca_test_app_rds.database_password}@${module.becca_test_app_rds.rds_instance_endpoint}/${module.becca_test_app_rds.database_name}"
  }
}
