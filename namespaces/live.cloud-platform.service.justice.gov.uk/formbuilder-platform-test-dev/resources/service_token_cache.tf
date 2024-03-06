module "service-token-cache-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  vpc_name = var.vpc_name

  application            = "formbuilderservice-token-cache"
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.micro"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "service-token-cache-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-service-token-cache-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    primary_endpoint_address = module.service-token-cache-elasticache.primary_endpoint_address
    auth_token               = module.service-token-cache-elasticache.auth_token
  }
}

module "token-cache-serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_name = "service-token-cache-terraform-module-formbuilder-platform-test-dev"

  serviceaccount_token_rotated_date = "06-03-2024"
  role_name = "service-token-cache-service-account-role"
  rolebinding_name = "service-token-cache-service-account-rolebinding"

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "configmaps"
      ]
      verbs = [
        "get",
        "list",
        "watch",
      ]
    }
  ]
}
