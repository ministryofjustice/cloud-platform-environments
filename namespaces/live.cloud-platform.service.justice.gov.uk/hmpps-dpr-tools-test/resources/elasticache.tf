module "hmpps_dpr_dpr_tools_ui_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis configuration
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  # Tags
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "hmpps_dpr_dpr_tools_ui_ec_cluster" {
  metadata {
    name      = "hmpps-dpr-tools-ui-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_dpr_dpr_tools_ui_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.hmpps_dpr_dpr_tools_ui_ec_cluster.member_clusters)
    auth_token               = module.hmpps_dpr_dpr_tools_ui_ec_cluster.auth_token
    replication_group_id     = module.hmpps_dpr_dpr_tools_ui_ec_cluster.replication_group_id
  }
}
