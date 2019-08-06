variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "risk_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
  force_ssl              = "true"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "risk_rds" {
  metadata {
    name      = "risk-rds-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    rds_instance_endpoint = "${module.risk_rds.rds_instance_endpoint}"
    database_name         = "${module.risk_rds.database_name}"
    database_username     = "${module.risk_rds.database_username}"
    database_password     = "${module.risk_rds.database_password}"
    rds_instance_address  = "${module.risk_rds.rds_instance_address}"
    url                   = "postgres://${module.risk_rds.database_username}:${module.risk_rds.database_password}@${module.risk_rds.rds_instance_endpoint}/${module.risk_rds.database_name}"
  }
}
