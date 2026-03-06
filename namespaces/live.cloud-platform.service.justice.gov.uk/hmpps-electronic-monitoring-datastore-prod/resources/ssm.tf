resource "aws_ssm_parameter" "athena_general_role_arn" {
  name        = "/${var.namespace}/athena_general_role_arn"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to query Athena for general EM order data"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "athena_general_role_arn" {
  name = "/${var.namespace}/athena_general_role_arn"
  with_decryption = true
}

resource "aws_ssm_parameter" "athena_specials_role_arn" {
  name        = "/${var.namespace}/athena_specials_role_arn"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/specials-placeholder"
  description = "ARN of the role used to query Athena for general & specials EM order data"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "athena_specials_role_arn" {
  name = "/${var.namespace}/athena_specials_role_arn"
  with_decryption = true
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
