module "hmpps_probation_mi_ui_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0"

  vpc_name = var.vpc_name

  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  enable_irsa            = true
}

resource "kubernetes_secret" "hmpps_probation_mi_ui_ec_cluster" {
  metadata {
    name      = "hmpps-probation-mi-ui-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_probation_mi_ui_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.hmpps_probation_mi_ui_ec_cluster.member_clusters)
    auth_token               = module.hmpps_probation_mi_ui_ec_cluster.auth_token
    replication_group_id     = module.hmpps_probation_mi_ui_ec_cluster.replication_group_id
  }
}

