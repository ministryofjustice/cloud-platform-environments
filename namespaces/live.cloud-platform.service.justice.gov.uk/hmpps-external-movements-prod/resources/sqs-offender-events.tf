module "offender_events_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name = "offender_events_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.offender_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-external-movements" # team name is used in queue name so setting to hard coded value
  environment_name       = var.environment
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
}

module "offender_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "offender_events_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-external-movements" # team name is used in queue name so setting to hard coded value
  environment_name       = var.environment
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
}

resource "aws_sns_topic_subscription" "offender_events_subscription" {
  topic_arn = data.aws_sns_topic.prison-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.offender_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "EXTERNAL_MOVEMENT_RECORD-INSERTED"
    ]
  })
}

resource "aws_sqs_queue_policy" "offender_events_queue_policy" {
  queue_url = module.offender_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "offender_events_queue_secret" {
  metadata {
    name      = "offender-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.offender_events_queue.sqs_id
    queue_arn  = module.offender_events_queue.sqs_arn
    queue_name = module.offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_events_dlq_secret" {
  metadata {
    name      = "offender-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.offender_events_dlq.sqs_id
    queue_arn  = module.offender_events_dlq.sqs_arn
    queue_name = module.offender_events_dlq.sqs_name
  }
}
