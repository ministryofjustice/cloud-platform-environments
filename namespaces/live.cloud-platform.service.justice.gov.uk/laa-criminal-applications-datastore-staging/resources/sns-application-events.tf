module "application-events-sns-topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.8.0"

  topic_display_name = "datastore-application-events"
  encrypt_sns_kms    = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

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
    access_key_id     = module.application-events-sns-topic.access_key_id
    secret_access_key = module.application-events-sns-topic.secret_access_key
    topic_name        = module.application-events-sns-topic.topic_name
    topic_arn         = module.application-events-sns-topic.topic_arn
  }
}

###
########### SNS subscriptions ###########
###

resource "aws_sns_topic_subscription" "events-review-subscription" {
  topic_arn = module.application-events-sns-topic.topic_arn
  endpoint  = "https://staging.review-criminal-legal-aid.service.justice.gov.uk/api/events"
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
