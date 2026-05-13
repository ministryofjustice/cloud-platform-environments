module "claims_events_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "claims-events"
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

resource "kubernetes_secret" "claims_events_sns_topic" {
  metadata {
    name      = "claims-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_name = module.claims_events_sns_topic.topic_name
    topic_arn  = module.claims_events_sns_topic.topic_arn
  }
}

###
########### SNS subscriptions ###########
###

resource "aws_sns_topic_subscription" "claims_events_queue_subscription" {
  provider  = aws.london
  topic_arn = module.claims_events_sns_topic.topic_arn
  endpoint  = module.sqs_queue.sqs_queue_arn
  protocol  = "sqs"
  raw_message_delivery = true
  filter_policy = jsonencode({
    SubmissionEventType = ["PARSE_BULK_SUBMISSION", "VALIDATE_SUBMISSION"]
  })
}