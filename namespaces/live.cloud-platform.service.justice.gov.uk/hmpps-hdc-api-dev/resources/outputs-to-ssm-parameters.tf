# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_irsa_policies = {
    (module.hmpps_hdc_api_queue.sqs_name)             = module.hmpps_hdc_api_queue.irsa_policy_arn
    (module.hmpps_hdc_api_dead_letter_queue.sqs_name) = module.hmpps_hdc_api_dead_letter_queue.irsa_policy_arn
  }
  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}