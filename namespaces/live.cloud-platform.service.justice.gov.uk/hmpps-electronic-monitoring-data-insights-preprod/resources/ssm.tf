data "aws_ssm_parameter" "athena_general_role_arn" {
  name = "/${var.namespace}/athena_general_role_arn"
  with_decryption = true
}

# -----------------------------------------------------------------------------
# This SSM parameter stores the MOD Platform IAM role ARN that the application
# will assume when querying Athena.
#
# IMPORTANT:
# - Terraform only creates the parameter and manages its name/lifecycle.
# - The *value* is intentionally set to a placeholder and must be updated
#   manually (or via platform automation) to the real MOD role ARN.
#
# The application reads this parameter via namespace Terraform and exposes it
# to the pod as ATHENA_GENERAL_IAM_ROLE.
# -----------------------------------------------------------------------------
resource "aws_ssm_parameter" "athena_general_role_arn" {
  name        = "/${var.namespace}/athena_general_role_arn"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to query Athena for general EM order data"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}