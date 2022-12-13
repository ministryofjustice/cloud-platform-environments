/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa-estimate-financial-eligibility-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.5"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa-estimate-financial-eligibility-elasticache" {
  metadata {
    name      = "laa-estimate-financial-eligibility-elasticache-instance-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.laa-estimate-financial-eligibility-elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.laa-estimate-financial-eligibility-elasticache.member_clusters)
    auth_token               = module.laa-estimate-financial-eligibility-elasticache.auth_token
    url                      = "rediss://dummyuser:${module.laa-estimate-financial-eligibility-elasticache.auth_token}@${module.laa-estimate-financial-eligibility-elasticache.primary_endpoint_address}:6379"
  }
}

