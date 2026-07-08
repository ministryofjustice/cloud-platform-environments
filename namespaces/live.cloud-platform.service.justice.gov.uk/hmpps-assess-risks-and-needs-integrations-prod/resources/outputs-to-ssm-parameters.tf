# Resources for the SQS queues used with the namespace
locals {
  sqs_irsa_policies = {
    (module.arns_coordinator_queue.sqs_name)             = module.arns_coordinator_queue.irsa_policy_arn
    (module.arns_coordinator_dead_letter_queue.sqs_name) = module.arns_coordinator_dead_letter_queue.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}