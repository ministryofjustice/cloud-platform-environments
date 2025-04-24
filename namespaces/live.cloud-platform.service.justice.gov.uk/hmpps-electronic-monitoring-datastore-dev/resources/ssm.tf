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
}
