locals {
  sqs_topics = {
    "Digital-Prison-Services-prod-manage_soc_cases_probation_offender_events_queue" = "offender-events-prod"
    "Digital-Prison-Services-prod-manage_soc_cases_probation_offender_events_dlq"   = "offender-events-prod"
    "Digital-Prison-Services-prod-manage_soc_cases_offender_events_queue"           = "offender-events-prod"
    "Digital-Prison-Services-prod-manage_soc_cases_offender_events_queue_dl"        = "offender-events-prod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

# IRSA for manage-soc-cases deployment
module "irsa_manage_soc_cases" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "manage-soc-cases"
  role_policy_arns = merge(
    { "rds" = module.dps_rds.irsa_policy_arn,
      "s3"  = module.manage_soc_cases_document_s3_bucket.irsa_policy_arn,
    "s3-extra" = aws_iam_policy.irsa_additional_s3_policy.arn },
    local.sqs_policies
  )
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_topics
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
