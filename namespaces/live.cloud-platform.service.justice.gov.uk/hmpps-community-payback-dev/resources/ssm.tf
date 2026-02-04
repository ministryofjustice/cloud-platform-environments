# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_irsa_policies = {
    (module.course_completion_events_queue.sqs_name) = module.course_completion_events_queue.irsa_policy_arn,
    (module.course_completion_events_dlq.sqs_name)   = module.course_completion_events_dlq.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags = {
      business-unit          = var.business_unit
      application            = var.application
      is-production          = var.is_production
      owner                  = var.team_name
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      namespace              = var.namespace
  }
}
