/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "apply-for-legal-aid-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=4.0"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "apply-for-legal-aid"
  business-unit          = "laa"
  application            = "laa-apply-for-legal-aid"
  is-production          = "false"
  environment-name       = "uat"
  infrastructure-support = "apply@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "apply-for-legal-aid-elasticache" {
  metadata {
    name      = "apply-for-legal-aid-elasticache-instance-output"
    namespace = "laa-apply-for-legalaid-uat"
  }

  data = {
    primary_endpoint_address = module.apply-for-legal-aid-elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.apply-for-legal-aid-elasticache.member_clusters)
    auth_token               = module.apply-for-legal-aid-elasticache.auth_token
  }
}

