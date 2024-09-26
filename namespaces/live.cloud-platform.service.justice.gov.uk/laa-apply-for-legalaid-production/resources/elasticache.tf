/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "apply-for-legal-aid-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"

  vpc_name               = var.vpc_name
  team_name              = "apply-for-legal-aid"
  business_unit          = "laa"
  application            = "laa-apply-for-legal-aid"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "apply-for-civil-legal-aid@digital.justice.gov.uk"
  node_type              = "cache.t4g.small"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "apply-for-legal-aid-elasticache" {
  metadata {
    name      = "apply-for-legal-aid-elasticache-instance-output"
    namespace = "laa-apply-for-legalaid-production"
  }

  data = {
    primary_endpoint_address = module.apply-for-legal-aid-elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.apply-for-legal-aid-elasticache.member_clusters)
    auth_token               = module.apply-for-legal-aid-elasticache.auth_token
  }
}
