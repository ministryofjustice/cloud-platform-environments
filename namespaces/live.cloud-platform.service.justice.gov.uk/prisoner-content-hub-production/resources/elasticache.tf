################################################################################
# Prisoner content hub Elasticache for ReDiS
################################################################################

module "drupal_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment-name
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.small"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-05-15"

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

module "frontend_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment-name
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.small"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-05-15"

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
  }
}
