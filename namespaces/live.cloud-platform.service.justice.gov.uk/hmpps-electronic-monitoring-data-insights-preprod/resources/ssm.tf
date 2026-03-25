data "aws_ssm_parameter" "athena_general_role_arn" {
  name = "/${var.namespace}/athena_general_role_arn"
  with_decryption = true
  depends_on = [
    aws_ssm_parameter.athena_general_role_arn
  ]
}

# -----------------------------------------------------------------------------
# This SSM parameter stores the MOD Platform IAM role ARN that the application
# will assume when querying Athena.
#
# The application reads this parameter via namespace Terraform and exposes it
# to the pod as ATHENA_GENERAL_IAM_ROLE.
#
# Note: this is currently set to point at dev data.
# -----------------------------------------------------------------------------
resource "aws_ssm_parameter" "athena_general_role_arn" {
  name        = "/${var.namespace}/athena_general_role_arn"
  type        = "SecureString"
  value       = "arn:aws:iam::800964199911:role/emdi_read_emds_data_dev"
  description = "ARN of the role used to query Athena for general EM order data"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}