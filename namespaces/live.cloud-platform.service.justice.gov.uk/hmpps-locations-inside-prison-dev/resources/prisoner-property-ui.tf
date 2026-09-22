# Cloud Platform resources for the hmpps-prisoner-property-ui frontend.
# Deploys into the shared hmpps-locations-inside-prison namespace alongside hmpps-prisoner-property-api.

# GitHub repo deploy access + application-insights secret (hmpps-prisoner-property-ui-application-insights)
module "hmpps-prisoner-property-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "hmpps-prisoner-property-ui"
  application                   = "hmpps-prisoner-property-ui"
  github_team                   = var.team_name
  environment                   = var.deployment_environment
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

# Redis (Elasticache) for the frontend's session store
module "prisoner_property_ui_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  node_type             = "cache.t4g.micro"
  engine_version        = "7.1"
  parameter_group_name  = "default.redis7"
  number_cache_clusters = "2"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_property_ui_elasticache_redis" {
  metadata {
    name      = "hmpps-prisoner-property-ui-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.prisoner_property_ui_elasticache_redis.primary_endpoint_address
    auth_token               = module.prisoner_property_ui_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.prisoner_property_ui_elasticache_redis.member_clusters)
    replication_group_id     = module.prisoner_property_ui_elasticache_redis.replication_group_id
  }
}
