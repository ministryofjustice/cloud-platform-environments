module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.4"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  db_allocated_storage        = "10"
  db_instance_class           = "db.t2.small"
  team_name                   = "${var.team_name}"
  business-unit               = "${var.business-unit}"
  application                 = "${var.application}"
  environment-name            = "${var.environment-name}"
  is-production               = "${var.is-production}"
  infrastructure-support      = "${var.infrastructure-support}"
  allow_major_version_upgrade = "true"
  force_ssl                   = "true"
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-emile-sample-app-staging"
    namespace = "${var.namespace}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
