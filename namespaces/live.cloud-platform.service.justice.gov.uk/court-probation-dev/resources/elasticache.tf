################################################################################
# Prepare a case Elasticache for ReDiS
################################################################################

module "pac_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  business_unit          = var.business_unit
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "pac_elasticache_redis" {
  metadata {
    name      = "pac-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.pac_elasticache_redis.primary_endpoint_address
    auth_token               = module.pac_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.pac_elasticache_redis.member_clusters)
  }
}

module "hmpps_probation_in_court_prepare_a_case_ui_elasticache_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.1.0"
  vpc_name                = var.vpc_name
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2023-07-04"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true
}

resource "kubernetes_secret" "hmpps_probation_in_court_prepare_a_case_ui_elasticache_redis" {
  metadata {
    name      = "hmpps-probation-in-court-prepare-a-case-ui-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_probation_in_court_prepare_a_case_ui_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_probation_in_court_prepare_a_case_ui_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_probation_in_court_prepare_a_case_ui_elasticache_redis.member_clusters)
  }
}