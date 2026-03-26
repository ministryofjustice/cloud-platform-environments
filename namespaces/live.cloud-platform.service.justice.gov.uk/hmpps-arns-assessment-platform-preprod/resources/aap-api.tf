module "hmpps_arns_assessment_platform_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-arns-assessment-platform-api"
  application                   = "hmpps-arns-assessment-platform-api"
  github_team                   = "hmpps-assessments-live"
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  reviewer_teams                = ["hmpps-assessments-live"]
}

# Note, redis is used for the cache of hot assessments
module "assessment-query-cache-elasticache-redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps_arns_assessment_platform_api.application
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

resource "kubernetes_secret" "assessment-query-cache-elasticache-redis" {
  metadata {
    name      = "assessment-query-cache-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.assessment-query-cache-elasticache-redis.primary_endpoint_address
    auth_token               = module.assessment-query-cache-elasticache-redis.auth_token
    member_clusters          = jsonencode(module.assessment-query-cache-elasticache-redis.member_clusters)
    replication_group_id     = module.assessment-query-cache-elasticache-redis.replication_group_id
  }
}
