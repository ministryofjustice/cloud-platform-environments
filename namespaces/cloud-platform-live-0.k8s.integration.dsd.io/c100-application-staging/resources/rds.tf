########################################
# C100 Application RDS (postgres engine)
########################################

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=2.4"

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
    name      = "rds-instance-c100-staging"
    namespace = "${var.namespace}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}

########################################
# postgres `analytics` unprivileged user
########################################

resource "random_string" "username" {
  length  = 8
  special = false
}

resource "random_string" "password" {
  length  = 16
  special = false
}

provider "postgresql" {
  alias    = "rds"
  host     = "${module.rds-instance.rds_instance_address}"
  port     = "${module.rds-instance.rds_instance_port}"
  username = "${module.rds-instance.database_username}"
  password = "${module.rds-instance.database_password}"
  database = "${module.rds-instance.database_name}"
}

resource "postgresql_role" "analytics" {
  provider = "postgresql.rds"
  name     = "analytics${random_string.username.result}"
  password = "${random_string.password.result}"
  login    = true
}

resource "kubernetes_secret" "rds-instance-analytics" {
  metadata {
    name      = "rds-instance-analytics-c100-staging"
    namespace = "${var.namespace}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${postgresql_role.analytics.name}:${postgresql_role.analytics.password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
