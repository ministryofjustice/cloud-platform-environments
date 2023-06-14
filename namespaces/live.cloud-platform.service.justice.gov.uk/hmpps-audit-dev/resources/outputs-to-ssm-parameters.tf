# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_irsa_policies = {
    (module.hmpps_audit_queue.sqs_name)             = module.hmpps_audit_queue.irsa_policy_arn
    (module.hmpps_audit_dead_letter_queue.sqs_name) = module.hmpps_audit_dead_letter_queue.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}
