module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  number_cache_clusters = var.number_cache_clusters
  # sized for micro in dev, preprod, suggest small for production
  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    auth_token               = module.elasticache_redis.auth_token
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}

resource "kubernetes_secret" "elasticache_redis_dev" {
  metadata {
    name      = "elasticache-redis-dev"
    namespace = "hmpps-portfolio-management-prod"
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    auth_token               = module.elasticache_redis.auth_token
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}

resource "helm_release" "hmpps_developer_portal_elasticache_alerts" {
  name       = "hmpps-dev-portal-elasticache-alerts"
  repository = "https://ministryofjustice.github.io/hmpps-helm-charts"
  chart      = "generic-aws-prometheus-alerts"
  version    = "1.0.2"
  namespace  = "hmpps-portfolio-management-dev"

  set {
    name  = "targetApplication"
    value = "hmpps-developer-portal"
  }

  set {
    name  = "alertSeverity"
    value = "digital-prison-service-dev"
  }

  set_list {
    name  = "elastiCacheAlertsClusterIds"
    value = module.elasticache_redis.member_clusters
  }

  # Set the alert for Elasticache's Engine CPU threshold value between 0 and 1.
  set {
    name  = "elastiCacheAlertsEngineCPUThreshold"
    value = "0.30"
  }

  set {
    name  = "elastiCacheAlertsEngineCPUThresholdMinutes"
    value = "5"
  }

  # Set the alert for Elasticache's CPU threshold - value between 0 and 100.
  set {
    name  = "elastiCacheAlertsCPUThreshold"
    value = "9"
  }

  set {
    name  = "elastiCacheAlertsCPUThresholdMinutes"
    value = "5"
  }

  # Set the alert for Elasticache's FreeMemory threshold - value should be above 150MB.
  set {
    name  = "elastiCacheAlertsFreeMemoryThreshold"
    value = "150"
  }

  set {
    name  = "elastiCacheAlertsFreeMemoryThresholdMinutes"
    value = "5"
  }
}
