module "hmpps-domain-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.8.0"

  topic_display_name = "hmpps-domain-events"

  business_unit            = var.business_unit
  application              = var.application
  is_production            = var.is_production
  team_name                = var.team_name
  environment_name         = var.environment-name
  infrastructure_support   = var.infrastructure_support
  namespace                = var.namespace
  additional_topic_clients = var.additional_topic_clients

  providers = {
    aws = aws.london
  }
}

resource "aws_ssm_parameter" "param-store-topic-arn" {
  type        = "String"
  name        = "/${var.namespace}/topic-arn"
  value       = module.hmpps-domain-events.topic_arn
  description = "SNS topic ARN for ${var.namespace}; use this parameter from other DPS pre prod namespaces"

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

resource "aws_iam_access_key" "key_2023" {
  user = module.hmpps-domain-events.user_name
}

resource "kubernetes_secret" "hmpps-domain-events-new-key" {
  metadata {
    name      = "hmpps-domain-events-new-key"
    namespace = "hmpps-domain-events-preprod"
  }

  data = {
    access_key_id     = aws_iam_access_key.key_2023.id
    secret_access_key = aws_iam_access_key.key_2023.secret
  }
}
