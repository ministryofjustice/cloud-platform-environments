module "hmpps_template_typescript" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-esupervision-ui"
  application = "hmpps-esupervision-ui"
  github_team = "stg-pathfinders"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["stg-pathfinders"]
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}


# Note, redis is a requirement for hmpps-template-typescript application.
module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps_template_typescript.application
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
