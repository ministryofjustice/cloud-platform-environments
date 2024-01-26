
# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

data "aws_iam_policy_document" "combined_local_sqs" {
  version = "2012-10-17"
  statement {
    sid     = "hmppsLocalSqs"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.hmpps_unused_deductions_queue.irsa_policy_arn,
      module.hmpps_unused_deductions_dead_letter_queue.irsa_policy_arn,
      module.hmpps_adjustments_prisoner_queue.irsa_policy_arn,
      module.hmpps_adjustments_prisoner_dead_letter_queue.irsa_policy_arn
    ]
  }
}

resource "aws_iam_policy" "combined_sqs" {
  policy = data.aws_iam_policy_document.combined_local_sqs.json
  # Tags
  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment_name
    infrastructure_support = var.infrastructure_support
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = merge(local.sns_policies, { combined_local_sqs = aws_iam_policy.combined_sqs.arn })
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
