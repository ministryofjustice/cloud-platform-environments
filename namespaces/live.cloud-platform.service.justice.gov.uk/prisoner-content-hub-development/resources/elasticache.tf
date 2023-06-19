################################################################################
# Prisoner content hub Elasticache for ReDiS
################################################################################

module "drupal_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.small"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace
  auth_token_rotated_date = "2023-03-21"

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
    access_key_id            = module.drupal_redis.access_key_id
    secret_access_key        = module.drupal_redis.secret_access_key
  }
}

module "frontend_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.small"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace
  auth_token_rotated_date = "2023-03-21"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "frontend_redis" {
  metadata {
    name      = "frontend-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.frontend_redis.primary_endpoint_address
    auth_token               = module.frontend_redis.auth_token
    member_clusters          = jsonencode(module.frontend_redis.member_clusters)
    access_key_id            = module.frontend_redis.access_key_id
    secret_access_key        = module.frontend_redis.secret_access_key
  }
}
