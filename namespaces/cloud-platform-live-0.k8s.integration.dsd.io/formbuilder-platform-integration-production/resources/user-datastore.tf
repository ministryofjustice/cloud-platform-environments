# auto-generated from fb-cloud-platforms-environments
##################################################
# User Datastore RDS
module "user-datastore-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=3.1"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "${var.db_backup_retention_period_user_datastore}"
  application                = "formbuilderuserdatastore"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
}

resource "kubernetes_secret" "user-datastore-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-user-datastore-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.user-datastore-rds-instance.database_username}:${module.user-datastore-rds-instance.database_password}@${module.user-datastore-rds-instance.rds_instance_endpoint}/${module.user-datastore-rds-instance.database_name}"
  }
}
