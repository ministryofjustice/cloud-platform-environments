variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "auth_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.8"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "delius oauth2 server"
  is-production          = "false"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
  rds_family             = "postgres10"
  force_ssl              = "true"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "auth_rds" {
  metadata {
    name      = "auth-rds-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    rds_instance_endpoint = "${module.auth_rds.rds_instance_endpoint}"
    database_name         = "${module.auth_rds.database_name}"
    database_username     = "${module.auth_rds.database_username}"
    database_password     = "${module.auth_rds.database_password}"
    rds_instance_address  = "${module.auth_rds.rds_instance_address}"
    url                   = "postgres://${module.auth_rds.database_username}:${module.auth_rds.database_password}@${module.auth_rds.rds_instance_endpoint}/${module.auth_rds.database_name}"
  }
}
