locals {
  arns_coordinator_api_sqs_queues = {
    "hmpps-assessments-dev-arns_coordinator_queue" = "hmpps-assess-risks-and-needs-integrations-dev"
  }

  arns_coordinator_api_sqs_policies = {
    for item in data.aws_ssm_parameter.arns_coordinator_api_irsa_policy_arns_sqs :
    item.name => item.value
  }
}

module "irsa_arns_assessment_view_api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-assess-risks-and-needs-coordinator-api"

  role_policy_arns = local.arns_coordinator_api_sqs_policies

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "arns_coordinator_api_irsa_policy_arns_sqs" {
  for_each = local.arns_coordinator_api_sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
