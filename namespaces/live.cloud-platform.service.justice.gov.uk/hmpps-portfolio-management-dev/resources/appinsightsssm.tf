
resource "aws_ssm_parameter" "param-store-appinsights_t3-arn" {
  type        = "String"
  name        = "/${var.namespace}/appinsights_t3-arn"
  value       = module.hmpps-portfolio-management-dev.appinsights_t3_arn
  description = "Application Inights T3 ARN for ${var.namespace}; use this parameter from other DPS production namespaces"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_ssm_parameter" "param-store-appinsights_preprod-arn" {
  type        = "String"
  name        = "/${var.namespace}/appinsights_preprod-arn"
  value       = module.hmpps-portfolio-management-dev.appinsights_preprod_arn
  description = "Application Inights preprod ARN for ${var.namespace}; use this parameter from other DPS production namespaces"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_ssm_parameter" "param-store-appinsights_prod-arn" {
  type        = "String"
  name        = "/${var.namespace}/appinsights_prod-arn"
  value       = module.hmpps-portfolio-management-dev.appinsights_preprod_arn
  description = "Application Inights prod ARN for ${var.namespace}; use this parameter from other DPS production namespaces"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}