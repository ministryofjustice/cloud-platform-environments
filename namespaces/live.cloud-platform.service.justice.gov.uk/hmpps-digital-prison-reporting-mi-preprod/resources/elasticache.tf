module "hmpps_digital_prison_reporting_mi_ui_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis configuration
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  # Tags
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
}

resource "kubernetes_secret" "hmpps_digital_prison_reporting_mi_ui_ec_cluster" {
  metadata {
    name      = "hmpps-digital-prison-reporting-mi-ui-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_digital_prison_reporting_mi_ui_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.hmpps_digital_prison_reporting_mi_ui_ec_cluster.member_clusters)
    auth_token               = module.hmpps_digital_prison_reporting_mi_ui_ec_cluster.auth_token
    access_key_id            = module.hmpps_digital_prison_reporting_mi_ui_ec_cluster.access_key_id
    secret_access_key        = module.hmpps_digital_prison_reporting_mi_ui_ec_cluster.secret_access_key
    replication_group_id     = module.hmpps_digital_prison_reporting_mi_ui_ec_cluster.replication_group_id
  }
}
