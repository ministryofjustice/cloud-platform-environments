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
