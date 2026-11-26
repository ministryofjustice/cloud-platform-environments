# data  "aws_ssm_parameter" "data_store_role" {
#   name = "/${var.namespace}/data_store_role"
#   with_decryption = true
# }

resource "aws_ssm_parameter" "data_store_role" {
  name        = "/${var.namespace}/data_store_role"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to ingest data from CPR relating to EM order data for dev account"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
