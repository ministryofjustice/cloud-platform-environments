
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  sqs_policies = {
    hmpps_remand_and_sentencing_prisoner_queue             = module.hmpps_remand_and_sentencing_prisoner_queue.irsa_policy_arn,
    hmpps_remand_and_sentencing_prisoner_dead_letter_queue = module.hmpps_remand_and_sentencing_prisoner_dead_letter_queue.irsa_policy_arn,
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-remand-and-sentencing-api"
  role_policy_arns     = merge(local.sqs_policies, local.sns_policies, { rds_policy = module.remand-and-sentencing-api-rds.irsa_policy_arn })
  # Tags
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
