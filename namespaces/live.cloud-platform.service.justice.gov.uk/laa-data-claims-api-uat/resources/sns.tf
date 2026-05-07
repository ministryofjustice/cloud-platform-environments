module "claims-events-sns-topic" {
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

resource "kubernetes_secret" "claims-events-sns-topic" {
  metadata {
    name      = "claims-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_name = module.claims-events-sns-topic.topic_name
    topic_arn  = module.claims-events-sns-topic.topic_arn
  }
}

###
########### SNS subscriptions ###########
###

resource "aws_sns_topic_subscription" "claims-events-queue-subscription" {
  provider  = aws.london
  topic_arn = module.claims-events-sns-topic.topic_arn
  endpoint  = data.aws_ssm_parameter.sqs_queue_arn.value
  protocol  = "sqs"
}