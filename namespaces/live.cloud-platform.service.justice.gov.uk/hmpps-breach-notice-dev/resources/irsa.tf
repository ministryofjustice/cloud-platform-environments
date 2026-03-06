data "aws_ssm_parameter" "audit_irsa_policy_arn" {
  name = "/hmpps-audit-${var.environment_name}/sqs/${local.audit_queue_name}/irsa-policy-arn"
}

data "aws_ssm_parameter" "domain_events_policy_arn" {
  name     = "/hmpps-domain-events-${var.environment_name}/sns/${var.domain_events_topic_name}/irsa-policy-arn"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = var.application
  namespace            = var.namespace
  role_policy_arns = {
    domain_events_queue = module.queue.irsa_policy_arn,
    domain_events_dlq   = module.dead-letter-queue.irsa_policy_arn,
    domain_events_topic = data.aws_ssm_parameter.domain_events_policy_arn.value,
    audit_queue         = data.aws_ssm_parameter.audit_irsa_policy_arn.value,
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}
