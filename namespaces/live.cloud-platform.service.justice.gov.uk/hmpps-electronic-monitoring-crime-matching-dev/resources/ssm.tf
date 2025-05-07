data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "athena_general_role_arn" {
  name = "/${var.namespace}/athena_general_role_arn"
  with_decryption = true
}