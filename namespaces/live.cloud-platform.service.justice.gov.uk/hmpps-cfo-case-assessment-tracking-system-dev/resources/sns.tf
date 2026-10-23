
module "sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "hmpps-cfo-case-assessment-tracking-system-${var.environment}"

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

# Expose the topic ARN to the application so it can publish messages.
resource "kubernetes_secret" "sns_topic" {
  metadata {
    name      = "sns-topic-output"
    namespace = var.namespace
  }

  data = {
    topic_arn  = module.sns_topic.topic_arn
    topic_name = module.sns_topic.topic_name
  }
}
