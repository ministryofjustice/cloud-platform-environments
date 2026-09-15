locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }

  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa-api" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0" # use the latest release
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name   = "hmpps-community-payback-api"
  role_policy_arns       = merge(
    {
        sqs     = module.hmpps_cp_domain_events_queue.irsa_policy_arn
    },
    {
        sqs_dlq = module.hmpps_cp_domain_events_dlq.irsa_policy_arn
    },
    {
        (module.course_completion_events_queue.sqs_name) = module.course_completion_events_queue.irsa_policy_arn
        (module.course_completion_events_dlq.sqs_name)   = module.course_completion_events_dlq.irsa_policy_arn
    },
    local.sns_policies
  )
}

module "irsa_ui" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-community-payback-ui-account"
  namespace            = var.namespace
  role_policy_arns = local.sqs_policies
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_supervisors_ui" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-community-payback-supervisors-ui-account"
  namespace            = var.namespace
  role_policy_arns = local.sqs_policies
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

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
