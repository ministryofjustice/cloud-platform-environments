module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-community-payback-api"
  application = "hmpps-community-payback-api"
  github_team = "hmpps-community-payback-devs"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  #reviewer_teams                = ["hmpps-dev-team-1", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "api_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps_template_kotlin.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  number_cache_clusters = var.number_cache_clusters
  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "api_elasticache_redis" {
  metadata {
    name      = "${module.hmpps_template_kotlin.application}-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    auth_token               = module.elasticache_redis.auth_token
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}
