########################################################
# C100 Application Redis Elasticache (for resque + jobs)
########################################################

module "redis-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=4.0"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis-elasticache" {
  metadata {
    name      = "elasticache-c100-production"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis-elasticache.primary_endpoint_address
    auth_token               = module.redis-elasticache.auth_token
  }
}

