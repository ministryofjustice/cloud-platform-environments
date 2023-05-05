# The value of this parameter is to be replaced manually, not wanting to put external acct IDs in public repository
resource "aws_ssm_parameter" "cica_prod_account_id" {
  name      = "cica_prod_account_id"
  type      = "String"
  value     = "0123456789"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}