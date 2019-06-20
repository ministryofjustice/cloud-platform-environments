module "ec-cluster-offender-management-allocation-manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.0"
  node_type              = "cache.m4.xlarge"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  application            = "offender-management-allocation-manager"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-staging" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-${var.environment-name}"
    namespace = "${var.namespace}"
  }

  data {
    primary_endpoint_address = "${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}"
    auth_token               = "${module.ec-cluster-offender-management-allocation-manager.auth_token}"
  }
}
