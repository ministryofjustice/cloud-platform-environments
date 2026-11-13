module "hmpps_assess_risks_and_needs_handover_service" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-assess-risks-and-needs-handover-service"
  application                   = "hmpps-assess-risks-and-needs-handover-service"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  selected_branch_patterns      = ["*"]
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

# The chart reads one secret named after the application. The template module only creates
# <application>-application-insights and <application>-client-creds, so this secret is added here.
# Placeholders follow the module's client credential secrets: "example value", never overwritten by terraform.
# The real values are set out of band and are not in this repository.
resource "kubernetes_secret" "handover_service" {
  metadata {
    name      = module.hmpps_assess_risks_and_needs_handover_service.application
    namespace = var.namespace
    annotations = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY   = data.aws_ssm_parameter.application_insights_key.value
    CLIENT_SP_SECRET                 = "example value"
    CLIENT_SAN_SECRET                = "example value"
    CLIENT_TIERING_ASSESSMENT_SECRET = "example value"
    JWK_PEM_ENCODED                  = "example value"
    JWK_PEM_SECRET                   = "example value"
    HANDOVER_CLIENT_ID               = "example value"
    HANDOVER_CLIENT_SECRET           = "example value"
  }

  lifecycle {
    ignore_changes = [data]
  }
}

module "handover_service_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = module.hmpps_assess_risks_and_needs_handover_service.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  number_cache_clusters = var.number_cache_clusters
  node_type             = "cache.t4g.micro"
  engine_version        = "7.0"
  parameter_group_name  = "default.redis7"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "handover_service_elasticache_redis" {
  metadata {
    name      = "hmpps-assess-risks-and-needs-integrations-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.handover_service_elasticache_redis.primary_endpoint_address
    auth_token               = module.handover_service_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.handover_service_elasticache_redis.member_clusters)
    replication_group_id     = module.handover_service_elasticache_redis.replication_group_id
  }
}
