#--Writes params for consumption by other namespaces
resource "aws_ssm_parameter" "sqs_queue_arn" {
  type        = "String"
  name        = "/${var.namespace}/sqs-queue-arn"
  value       = module.queue.sqs_arn
  description = "SQS Queue ARN"
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

resource "aws_ssm_parameter" "sqs_irsa_policy_arn" {
  type        = "String"
  name        = "/${var.namespace}/sqs-policy-arn"
  value       = module.queue.irsa_policy_arn
  description = "SQS IRSA Policy ARN"
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