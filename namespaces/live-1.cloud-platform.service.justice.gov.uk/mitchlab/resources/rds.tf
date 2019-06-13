variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.4"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "cloud-platform"
  business-unit          = "cloud-platform"
  application            = "mitchlab"
  is-production          = "false"
  environment-name       = "lab"
  infrastructure-support = "dimitrios.karagiannis@digital.justice.gov.uk"
  force_ssl              = "false"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = "mitchlab"
  }

  data {
    rds_instance_endpoint = "${module.rds.rds_instance_endpoint}"
    database_name         = "${module.rds.database_name}"
    database_username     = "${module.rds.database_username}"
    database_password     = "${module.rds.database_password}"
    rds_instance_address  = "${module.rds.rds_instance_address}"
    url                   = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}
