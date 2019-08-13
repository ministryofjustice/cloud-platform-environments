module "ec-cluster-offender-management-allocation-manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.1"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  application            = "offender-management-allocation-manager"
  is-production          = "${var.is-production}"
  node_type              = "cache.m4.large"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-production" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-${var.environment-name}"
    namespace = "${var.namespace}"
  }

  data {
    primary_endpoint_address = "${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}"
    auth_token               = "${module.ec-cluster-offender-management-allocation-manager.auth_token}"
  }
}
