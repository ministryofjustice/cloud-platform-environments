# data "aws_ssm_parameter" "data_store_general_role_arn" {
#   name = "/${var.namespace}/data_store_general_role_arn"
#   with_decryption = true
# }

resource "aws_ssm_parameter" "data_store_general_role_arn" {
  name        = "/${var.namespace}/data_store_general_role_arn"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to query general EM order data"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
