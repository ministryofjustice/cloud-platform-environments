module "hmpps_community_accommodation_tier_2_ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-community-accommodation-tier-2-ui"
  application = "hmpps-community-accommodation-tier-2-ui"
  github_team = "hmpps-community-accommodation"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-temporary-accommodation", "hmpps-community-accommodation"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "feature-dev/*"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}


resource "kubernetes_secret" "elasticache_redis" {
  metadata {
    name      = "${module.hmpps_template_typescript.application}-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    auth_token               = module.elasticache_redis.auth_token
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}