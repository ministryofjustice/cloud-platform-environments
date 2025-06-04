# The value of this parameter is to be replaced manually, not wanting to put external acct IDs in public repository
resource "aws_ssm_parameter" "cica_prod_account_id" {
  name      = "/claim-criminal-injuries-compensation-prod/cica-prod-account-id"
  type      = "SecureString"
  value     = "0123456789"
  overwrite = false

  tags = {
      business-unit          = var.business_unit
      application            = var.application
      is-production          = var.is_production
      owner                  = var.team_name
      environment-name       = var.environment-name
      infrastructure-support = var.infrastructure_support
      namespace              = var.namespace
  }
  
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}