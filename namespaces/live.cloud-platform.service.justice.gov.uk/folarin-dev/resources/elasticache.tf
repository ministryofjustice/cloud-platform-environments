module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  namespace              = var.namespace

  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  # Test: specify AZs to skip eu-west-2b (which has capacity issues)
  preferred_cache_cluster_azs = ["eu-west-2a", "eu-west-2c"]
  number_cache_clusters       = "2"

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

# Test: no AZs specified, validating default behavior
module "elasticache_redis_default_azs" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  namespace              = var.namespace

  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  number_cache_clusters = "2"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis_default_azs" {
  metadata {
    name      = "elasticache-redis-default-azs"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis_default_azs.primary_endpoint_address
    auth_token               = module.elasticache_redis_default_azs.auth_token
    member_clusters          = jsonencode(module.elasticache_redis_default_azs.member_clusters)
    replication_group_id     = module.elasticache_redis_default_azs.replication_group_id
  }
}

# Backward compatibility test: switched from 8.1.0 to feature branch
module "elasticache_redis_official" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  namespace              = var.namespace

  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  number_cache_clusters = "2"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis_official" {
  metadata {
    name      = "elasticache-redis-official"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis_official.primary_endpoint_address
    auth_token               = module.elasticache_redis_official.auth_token
    member_clusters          = jsonencode(module.elasticache_redis_official.member_clusters)
    replication_group_id     = module.elasticache_redis_official.replication_group_id
  }
}
