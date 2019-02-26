########################################
# C100 Application RDS (postgres engine)
########################################

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  db_backup_retention_period = "${var.db_backup_retention_period}"
  application                = "${var.application}"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
  db_engine_version          = "10"
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-c100-production"
    namespace = "${var.namespace}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
