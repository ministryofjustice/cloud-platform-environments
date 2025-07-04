# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_irsa_policies = {
    (module.prisoner_from_nomis_courtsentencing_queue.sqs_name)             = module.prisoner_from_nomis_courtsentencing_queue.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.default_tags
}
