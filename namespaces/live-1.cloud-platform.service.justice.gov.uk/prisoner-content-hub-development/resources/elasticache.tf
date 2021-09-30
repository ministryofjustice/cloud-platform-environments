################################################################################
# Prisoner content hub Elasticache for ReDiS
################################################################################

module "drupal_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.3"
  cluster_name           = var.cluster_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  node_type              = "cache.t3.small"
  engine_version         = "5.0.6"
  parameter_group_name   = "default.redis5.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "drupal_redis" {
  metadata {
    name      = "drupal-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.drupal_redis.primary_endpoint_address
    auth_token               = module.drupal_redis.auth_token
    member_clusters          = jsonencode(module.drupal_redis.member_clusters)
  }
}

