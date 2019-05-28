variable "cluster_name" {}
variable "cluster_state_bucket" {}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.3"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  team_name                  = "${var.team_name}"
  business-unit              = "${var.business-unit}"
  application                = "${var.application}"
  is-production              = "${var.is-production}"
  environment-name           = "${var.environment-name}"
  infrastructure-support     = "${var.email}"
  db_engine                  = "postgres"
  db_engine_version          = "10.6"
  db_instance_class          = "db.t2.small"
  db_allocated_storage       = "5"
  db_name                    = "datacaptureservice"
  db_backup_retention_period = "${var.db_backup_retention_period}"
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-production"
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
