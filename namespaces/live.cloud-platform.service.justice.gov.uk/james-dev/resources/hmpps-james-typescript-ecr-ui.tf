module "hmpps_james_typescript_ecr_ui" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token         = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                = "hmpps-james-typescript-ecr-ui"
  application                = "hmpps-james-typescript-ecr-ui"
  github_team                = "hmpps-sre"
  environment                = var.environment                   # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams             = ["hmpps-sre", "hmpps-developers"] # Optional team that should review deployments to this environment.
  selected_branch_patterns   = ["main", "**/**", "**"]           # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  enable_ecr                    = true
}


# Note, redis is a requirement for hmpps-james-typescript-ecr-ui application.
module "james_typescript_ecr_ui_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps_james_typescript_ecr_ui.application
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

resource "kubernetes_secret" "james_typescript_ecr_ui_redis" {
  metadata {
    name      = "${module.hmpps_james_typescript_ecr_ui.application}-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.james_typescript_ecr_ui_redis.primary_endpoint_address
    auth_token               = module.james_typescript_ecr_ui_redis.auth_token
    member_clusters          = jsonencode(module.james_typescript_ecr_ui_redis.member_clusters)
    replication_group_id     = module.james_typescript_ecr_ui_redis.replication_group_id
  }
}
