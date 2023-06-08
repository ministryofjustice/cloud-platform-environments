module "service-token-cache-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"

  vpc_name = var.vpc_name

  application            = "formbuilderservice-token-cache"
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.medium"
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
