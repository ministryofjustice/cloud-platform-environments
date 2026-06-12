module "redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  snapshot_window         = "01:00-02:00"
  auth_token_rotated_date = "2023-07-04"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

  module "redis_secondary" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0"

    # VPC configuration
    vpc_name = var.vpc_name

    # Redis cluster configuration (secondary instance)
    node_type               = "cache.t4g.micro"
    engine_version          = "7.0"
    parameter_group_name    = "default.redis7"
    snapshot_window         = "01:00-02:00"
    auth_token_rotated_date = "2023-07-04"

    # Tags (mark application/environment so it's identifiable as secondary)
    business_unit          = var.business_unit
    application            = "${var.application}-secondary"
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = "${var.environment}-secondary"
    infrastructure_support = var.infrastructure_support
  }

resource "kubernetes_secret" "ec-cluster-output" {
  metadata {
    name      = "ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis.primary_endpoint_address
    member_clusters          = jsonencode(module.redis.member_clusters)
    auth_token               = module.redis.auth_token
    replication_group_id     = module.redis.replication_group_id
  }
}

resource "kubernetes_secret" "app-redis" {
  metadata {
    name      = "app-redis"
    namespace = var.namespace
  }

  data = {
    APP_REDIS_ENDPOINT = module.redis.primary_endpoint_address
    APP_REDIS_PASSWORD = module.redis.auth_token
    APP_REDIS_PORT     = "6379"
  }
}

resource "kubernetes_secret" "ec-cluster-output-secondary" {
  metadata {
    name      = "ec-cluster-output-secondary"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis_secondary.primary_endpoint_address
    member_clusters          = jsonencode(module.redis_secondary.member_clusters)
    auth_token               = module.redis_secondary.auth_token
    replication_group_id     = module.redis_secondary.replication_group_id
  }
}

resource "kubernetes_secret" "app-redis-secondary" {
  metadata {
    name      = "app-redis-secondary"
    namespace = var.namespace
  }

  data = {
    APP_REDIS_ENDPOINT = module.redis_secondary.primary_endpoint_address
    APP_REDIS_PASSWORD = module.redis_secondary.auth_token
    APP_REDIS_PORT     = "6379"
  }
}
