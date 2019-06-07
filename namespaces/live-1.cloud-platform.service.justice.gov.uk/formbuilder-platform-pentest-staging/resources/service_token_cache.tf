# auto-generated from fb-cloud-platforms-environments
########################################################
# Service Token Cache Elasticache Redis (for resque + job logging)
module "service-token-cache-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.0"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  application            = "formbuilderservice-token-cache"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "service-token-cache-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-service-token-cache-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    primary_endpoint_address = "${module.service-token-cache-elasticache.primary_endpoint_address}"
    auth_token               = "${module.service-token-cache-elasticache.auth_token}"
  }
}
