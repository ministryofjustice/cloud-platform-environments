module "ec_live0_to_live1_migration" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=2.1"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
}

resource "kubernetes_secret" "ec_sec_live0_to_live1_migration" {
  metadata {
    name      = "ec-live0-to-live1-migration-${var.environment-name}"
    namespace = "${var.namespace}"
  }

  data {
    primary_endpoint_address = "${module.ec_live0_to_live1_migration.primary_endpoint_address}"
    auth_token               = "${module.ec_live0_to_live1_migration.auth_token}"
  }
}
