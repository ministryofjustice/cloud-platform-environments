# Add the names of the SQS queues & SNS topics which the app needs permissions to access.
# The value of each item should be the namespace where the queue or topic was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  # The names of the queues used and the namespace which created them
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev",
  }

  # The names of the SNS topics used and the namespace which created them
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }

  # The names of s3 buckets and the namespace that created them
  cross_namespace_s3_buckets = {
    "cloud-platform-67a5a926dc2dc743f76a6c3367d47158" = "hmpps-prison-person-api-dev"
  }

  sqs_policies            = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies            = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  cross_namespace_s3_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_cross_namespace_s3 : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-document-management-api"
  role_policy_arns = merge(local.sqs_policies, local.sns_policies, local.cross_namespace_s3_policies, {
    s3       = module.s3.irsa_policy_arn
    s3images = module.s3-images.irsa_policy_arn
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_cross_namespace_s3" {
  for_each = local.cross_namespace_s3_buckets
  name     = "/${each.value}/s3/${each.key}/irsa-policy-arn"
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.1.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}
