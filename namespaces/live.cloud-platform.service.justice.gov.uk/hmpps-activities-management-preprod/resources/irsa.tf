# Add the names of the SQS queues & SNS topics which the app needs permissions to access.
# The value of each item should be the namespace where the queue or topic was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  # The names of the queues used and the namespace which created them
  sqs_queues = {
    "Digital-Prison-Services-preprod-hmpps_audit_queue"              = "hmpps-audit-preprod",
    "Digital-Prison-Services-preprod-activities_domain_events_queue" = "hmpps-domain-events-preprod",
    "Digital-Prison-Services-preprod-activities_domain_events_dl"    = "hmpps-domain-events-preprod"
  }

  # The names of the SNS topics used and the namespace which created them
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }

  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-activities-management-api"
  role_policy_arns     = merge(
    local.sqs_policies, 
    local.sns_policies, 
    {
      activities_rds_policy = module.activities_rds.irsa_policy_arn,
    },
    { analytical-platform   = aws_iam_policy.analytical-platform.arn },
    { (module.update_from_external_system_events_queue.sqs_name) = module.update_from_external_system_events_queue.irsa_policy_arn },
    { (module.update_from_external_system_events_dlq.sqs_name) = module.update_from_external_system_events_dlq.irsa_policy_arn }
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
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

resource "aws_iam_policy" "analytical-platform" {
  name   = "${var.namespace}-analytical-platform"
  policy = data.aws_iam_policy_document.analytical-platform.json
  # NB: IAM policy name must be unique within Cloud Platform

  tags = {
    business-unit          = var.business_unit
    team_name              = var.team_name
    application            = var.application
    is-production          = var.is_production
    namespace              = var.namespace
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

data "aws_iam_policy_document" "analytical-platform" {
  statement {
    actions = [
      "s3:Putobject",
      "s3:PutobjectAcl"
    ]
    resources = [
      "arn:aws:s3:::moj-reg-preprod/landing/${var.namespace}/*",
      "arn:aws:s3:::moj-reg-preprod/landing/${var.namespace}/"
    ]
  }
}