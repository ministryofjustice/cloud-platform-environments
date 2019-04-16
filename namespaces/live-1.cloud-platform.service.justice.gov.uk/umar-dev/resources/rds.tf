
/* These two variables (cluster_name & cluster_state_bucket) are automatically populated via cloud-platform-environments */

variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "umar-dev-rds-team" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.0"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "form-builder"
  business-unit          = "transformed-department"
  application            = "umar-dev-rds-app"
  is-production          = "false"
  environment-name       = "rds-dev"
  infrastructure-support = "umar.hansa@digtal.justice.gov.uk"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "umar-dev-rds-team" {
  metadata {
    name      = "umar-dev-rds-app-name"
    namespace = "umar-dev"
  }

  data {
    rds_instance_endpoint = "${module.umar-dev-rds-team.rds_instance_endpoint}"
    database_name         = "${module.umar-dev-rds-team.database_name}"
    database_username     = "${module.umar-dev-rds-team.database_username}"
    database_password     = "${module.umar-dev-rds-team.database_password}"
    rds_instance_address  = "${module.umar-dev-rds-team.rds_instance_address}"
  }
}
