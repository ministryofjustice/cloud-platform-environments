# Create SSM parameters containing SNS topic ARN's for hmpps-audit to subscribe to
resource "aws_ssm_parameter" "sns_common_topic_arn_ssm" {
  type     = "String"
  name     = "/${var.namespace}/sns/common/sns-topic-arn"
  value    = module.hmpps_pfs_common.topic_arn
  tags     = local.tags
}

resource "aws_ssm_parameter" "sns_audit_topic_arn_ssm" {
  type     = "String"
  name     = "/${var.namespace}/sns/audit/sns-topic-arn"
  value    = module.hmpps_pfs_audit.topic_arn
  tags     = local.tags
}

# Retrieve an SSM parameter containing the IRSA ARNs required to allow publish to SNS topics
data "aws_ssm_parameter" "additional_sns_clients" {
  for_each = toset(var.additional_topic_clients)
  name     = "/${each.value}/irsa/irsa-arn"
}

locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }

  pfs_analytics_client_arns = [for param in data.aws_ssm_parameter.additional_sns_clients : param.value]
}