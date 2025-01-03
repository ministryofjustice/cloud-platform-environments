# Add the names of the SQS queues & SNS topics which the app needs permissions to access.
# The value of each item should be the namespace where the queue or topic was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }

  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  sqs_policies = {
    domain-events-queue = module.domain-events-queue.irsa_policy_arn,
    domain-events-dlq   = module.domain-events-dlq.irsa_policy_arn,
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-prison-person-api"
  role_policy_arns = merge(
    local.sns_policies,
    local.sqs_policies,
    {
    s3_distinguishing_marks = module.s3-distinguishing-mark-images.irsa_policy_arn
  }
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
