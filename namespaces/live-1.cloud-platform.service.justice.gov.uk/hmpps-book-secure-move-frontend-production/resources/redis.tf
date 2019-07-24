module "redis-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.0"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  application            = "${var.application}"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "redis-elasticache" {
  metadata {
    name      = "elasticache-hmpps-book-secure-move-frontend-production"
    namespace = "${var.namespace}"
  }

  data {
    primary_endpoint_address = "${module.redis-elasticache.primary_endpoint_address}"
    auth_token               = "${module.redis-elasticache.auth_token}"
  }
}
