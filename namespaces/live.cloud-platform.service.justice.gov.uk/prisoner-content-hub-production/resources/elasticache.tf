################################################################################
# Prisoner content hub Elasticache for ReDiS
################################################################################

module "drupal_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.4"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t3.medium"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
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

