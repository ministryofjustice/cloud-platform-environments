module "hmpps-domain-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "hmpps-domain-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_ssm_parameter" "param-store-topic-arn" {
  type        = "String"
  name        = "/${var.namespace}/topic-arn"
  value       = module.hmpps-domain-events.topic_arn
  description = "SNS topic ARN for hmpps-domain-events-dev; use this parameter from other DPS dev namespaces"

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
