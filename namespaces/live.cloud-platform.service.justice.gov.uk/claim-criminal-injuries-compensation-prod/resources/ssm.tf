# The value of this parameter is to be replaced manually, not wanting to put external acct IDs in public repository
resource "aws_ssm_parameter" "cica_prod_account_id" {
  name      = "/claim-criminal-injuries-compensation-prod/cica-prod-account-id"
  type      = "SecureString"
  value     = "0123456789"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}