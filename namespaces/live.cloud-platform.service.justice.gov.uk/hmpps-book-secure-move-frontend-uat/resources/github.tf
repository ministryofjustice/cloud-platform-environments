# For Cloud Platform deployed projects based on the hmpps-template-typescript template:
# Make a copy of this file in your namespace, then modify according to the instructions here:
# https://tech-docs.hmpps.service.justice.gov.uk/creating-new-services/creating-resources-in-cloud-platform

module "hmpps_template_typescript" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-book-secure-move-frontend"
  application                   = "hmpps-book-secure-move-frontend"
  github_team                   = var.team_name
  environment                   = var.environment-name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.deployment_environment
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

# Note, redis is a requirement for hmpps-template-typescript application.
module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps_template_typescript.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
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
