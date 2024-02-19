module "application-events-sns-topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "datastore-application-events"
  encrypt_sns_kms    = true

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

resource "kubernetes_secret" "application-events-sns-topic" {
  metadata {
    name      = "application-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_name = module.application-events-sns-topic.topic_name
    topic_arn  = module.application-events-sns-topic.topic_arn
  }
}

###
########### SNS subscriptions ###########
###

resource "aws_sns_topic_subscription" "events-review-subscription" {
  topic_arn = module.application-events-sns-topic.topic_arn
  endpoint  = "https://review-criminal-legal-aid.service.justice.gov.uk/api/events"
  protocol  = "https"

  raw_message_delivery   = false
  endpoint_auto_confirms = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.application-events-dlq.sqs_arn
  })

  delivery_policy = jsonencode({
    "healthyRetryPolicy" = {
      "backoffFunction"    = "exponential"
      "numRetries"         = 30
      "minDelayTarget"     = 5
      "maxDelayTarget"     = 120
      "numNoDelayRetries"  = 3
      "numMinDelayRetries" = 2
      "numMaxDelayRetries" = 15
    }
    "throttlePolicy" = {
      "maxReceivesPerSecond" = 10
    }
  })

  filter_policy = jsonencode({
    event_name = [
      "apply.submission"
    ]
  })
}
