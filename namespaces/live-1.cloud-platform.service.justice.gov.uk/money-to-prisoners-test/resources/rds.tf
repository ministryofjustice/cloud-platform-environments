# https://github.com/ministryofjustice/cloud-platform-terraform-rds-instance

variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.6"

  providers = {
    aws = "aws.london"
  }

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.email}"
  rds_family             = "postgres10"
  db_engine              = "postgres"
  db_engine_version      = "10.10"
  db_instance_class      = "db.t2.small"
  db_allocated_storage   = "5"
  db_name                = "mtp_api"
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds"
    namespace = "${var.namespace}"
  }

  data {
    rds_instance_endpoint = "${module.rds.rds_instance_endpoint}"
    database_name         = "${module.rds.database_name}"
    database_username     = "${module.rds.database_username}"
    database_password     = "${module.rds.database_password}"
    rds_instance_address  = "${module.rds.rds_instance_address}"
    rds_instance_port     = "${module.rds.rds_instance_port}"
  }
}
