module "ec-cluster-prison-visits-booking-staff" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=2.1"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  application            = "prison-visits-booking-staff"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
}

resource "kubernetes_secret" "ec-cluster-prison-visits-booking-staff" {
  metadata {
    name      = "elasticache-prison-visits-booking-token-cache-${var.environment-name}"
    namespace = "${var.namespace}"
  }

  data {
    primary_endpoint_address = "${module.ec-cluster-prison-visits-booking-staff.primary_endpoint_address}"
    auth_token               = "${module.ec-cluster-prison-visits-booking-staff.auth_token}"
  }
}
