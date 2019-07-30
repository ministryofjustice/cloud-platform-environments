module "jason-lab-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.5"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  application            = "${var.application}"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "jason-lab-rds-instance" {
  metadata {
    name      = "jason-lab-${var.environment-name}"
    namespace = "jason-lab"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.jason-lab-rds-instance.database_username}:${module.jason-lab-rds-instance.database_password}@${module.jason-lab-rds-instance.rds_instance_endpoint}/${module.jason-lab-rds-instance.database_name}"
  }
}
