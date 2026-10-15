# Add Service account role ARN to SSM parameter to be consumed by hmpps-pfs-web-analytics-dev
resource "aws_ssm_parameter" "irsa_policy_arn_ssm" {
  type     = "String"
  name     = "/${var.namespace}/irsa/irsa-arn"
  value    = module.irsa.role_arn
  tags = {
      business-unit          = var.business_unit
      application            = var.application
      is-production          = var.is_production
      owner                  = var.team_name
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      namespace              = var.namespace
  }
}
