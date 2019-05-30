variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.2"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.email}"
  db_engine              = "postgres"
  db_engine_version      = "9.4"
  db_instance_class      = "db.t2.small"
  db_allocated_storage   = "5"
  db_name                = "laalaa"
}

resource "kubernetes_secret" "db" {
  metadata {
    name      = "db"
    namespace = "${var.namespace}"
  }

  data {
    endpoint = "${module.rds.rds_instance_endpoint}"
    name     = "${module.rds.database_name}"
    user     = "${module.rds.database_username}"
    password = "${module.rds.database_password}"
    host     = "${module.rds.rds_instance_address}"
    port     = "${module.rds.rds_instance_port}"
    url      = "postgis://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}
