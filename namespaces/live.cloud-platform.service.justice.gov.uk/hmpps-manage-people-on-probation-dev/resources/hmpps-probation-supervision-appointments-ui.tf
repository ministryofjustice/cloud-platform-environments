module "hmpps-probation-supervision-appointments-ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-probation-supervision-appointments-ui"
  application = "hmpps-probation-supervision-appointments-ui"
  github_team = "hmpps-manage-people-on-probation"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  #reviewer_teams                = ["hmpps-dev-team-1", "hmpps-dev-team-2"] # Optional team that should review deployments to this environment.
  #selected_branch_patterns      = ["main", "release/*", "feature/*"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  enable_ecr                    = true
  ecr_deletion_protection       = false
}


# Note, redis is a requirement for hmpps-template-typescript application.
module "supervision-appointments_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps-probation-supervision-appointments-ui.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  number_cache_clusters = var.number_cache_clusters
  # sized for micro in dev, preprod, suggest small for production
  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  enable_irsa = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis_supervision-appointments-ui" {
  metadata {
    name      = "${module.hmpps-probation-supervision-appointments-ui.application}-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.supervision-appointments_elasticache_redis.primary_endpoint_address
    auth_token               = module.supervision-appointments_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.supervision-appointments_elasticache_redis.member_clusters)
    replication_group_id     = module.supervision-appointments_elasticache_redis.replication_group_id
  }
}
