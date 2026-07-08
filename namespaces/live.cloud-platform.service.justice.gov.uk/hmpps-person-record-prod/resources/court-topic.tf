module "cpr_court_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "cpr-court-topic"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cpr_court_topic" {
  metadata {
    name      = "court-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn         = module.cpr_court_topic.topic_arn
  }
}

resource "aws_ssm_parameter" "cpr_court_topic_sns_arn" {
  type        = "String"
  name        = "/${var.namespace}/cpr-court-topic-sns-arn"
  value       = module.cpr_court_topic.topic_arn
  description = "ARN of SNS Topic"
  tags        = local.default_tags
}