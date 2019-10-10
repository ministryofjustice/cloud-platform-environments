variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "dps_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.1"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  application            = "${var.application}"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
  number_cache_clusters  = "${var.number_cache_clusters}"
  node_type              = "${var.node-type}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "dps_redis" {
  metadata {
    name      = "dps-redis"
    namespace = "${var.namespace}"
  }

  data {
    primary_endpoint_address = "${module.dps_redis.primary_endpoint_address}"
    member_clusters          = "${jsonencode(module.dps_redis.member_clusters)}"
    auth_token               = "${module.dps_redis.auth_token}"
  }
}
