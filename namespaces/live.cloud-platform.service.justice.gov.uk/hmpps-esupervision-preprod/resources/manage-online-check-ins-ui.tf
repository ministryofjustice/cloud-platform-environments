module "hmpps_manage_online_check_ins_ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-06-20"
  github_repo = "hmpps-manage-online-check-ins-ui"
  application = "hmpps-manage-online-check-ins-ui"
  github_team = "stg-pathfinders"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  reviewer_teams                = ["stg-pathfinders"]
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

# Share the existing elasticache_redis instance with this application ()
resource "kubernetes_secret" "manage_online_check_ins_elasticache_redis" {
  metadata {
    name      = "${module.hmpps_manage_online_check_ins_ui.application}-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    auth_token               = module.elasticache_redis.auth_token
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}
