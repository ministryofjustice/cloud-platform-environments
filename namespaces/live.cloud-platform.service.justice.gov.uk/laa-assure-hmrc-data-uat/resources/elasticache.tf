module "elasticache" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.application
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  node_type              = "cache.t4g.micro"

  # Consider setting the engine to a recent version (defaults to 5.0.6)
  engine_version = "6.x"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache" {
  metadata {
    name      = "elasticache"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.elasticache.member_clusters)
    auth_token               = module.elasticache.auth_token
    access_key_id            = module.elasticache.access_key_id
    secret_access_key        = module.elasticache.secret_access_key
    replication_group_id     = module.elasticache.replication_group_id
  }
}
