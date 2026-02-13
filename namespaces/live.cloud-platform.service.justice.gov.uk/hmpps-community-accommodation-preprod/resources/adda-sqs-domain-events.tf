module "adda_domain_events_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name = "adda_domain_events_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.adda_domain_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "adda_domain_events_queue_policy" {
  queue_url = module.adda_domain_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

module "adda_domain_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "adda_domain_events_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


resource "aws_sns_topic_subscription" "adda_domain_events_subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.adda_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "sas.accommodation.updated",
    ]
  })
}


resource "kubernetes_secret" "adda_domain_events_queue_secret" {
  metadata {
    name      = "adda-domain-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.adda_domain_events_queue.sqs_id
    queue_arn  = module.adda_domain_events_queue.sqs_arn
    queue_name = module.adda_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "adda_domain_events_dlq_secret" {
  metadata {
    name      = "adda-domain-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.adda_domain_events_dlq.sqs_id
    queue_arn  = module.adda_domain_events_dlq.sqs_arn
    queue_name = module.adda_domain_events_dlq.sqs_name
  }
}
