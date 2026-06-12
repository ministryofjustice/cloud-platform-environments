locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
    sqs_policies = {
    bulk_comparison_queue                   = module.bulk_comparison_queue.irsa_policy_arn,
    bulk_comparison_dead_letter_queue       = module.bulk_comparison_dead_letter_queue.irsa_policy_arn,
    bulk_comparison_alt_queue               = module.bulk_comparison_alt_queue.irsa_policy_arn,
    bulk_comparison_alt_dead_letter_queue   = module.bulk_comparison_alt_dead_letter_queue.irsa_policy_arn,
  }
}

module "irsa" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "calculate-release-dates-api-preprod"
  role_policy_arns       = merge(
    local.sns_policies,
    local.sqs_policies,
    {
      rds_policy = module.calculate_release_dates_api_rds.irsa_policy_arn,
      replica_rds_policy = module.read_replica.irsa_policy_arn,
    }
  )
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}
