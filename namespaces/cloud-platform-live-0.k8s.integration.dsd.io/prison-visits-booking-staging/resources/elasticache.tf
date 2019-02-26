module "ec-cluster-prison-visits-booking-staff" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster"
  cluster_name           = "cloud-platform-live-0"
  cluster_state_bucket   = "live-0-state-bucket"
  team_name              = "prison-visits-booking"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  node_type              = "cache.m3.medium"
  number_cache_clusters  = "3"
  application            = "prison-visits-booking-staff"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "pvb-technical-support@digtal.justice.gov.uk"
}
