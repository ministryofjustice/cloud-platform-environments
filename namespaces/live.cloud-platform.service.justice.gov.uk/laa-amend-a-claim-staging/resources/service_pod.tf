module "irsa" {
  role_policy_arns = {
        elasticache_redis  = module.elasticache_redis.irsa_policy_arn
    }
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0"

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}