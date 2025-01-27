resource "aws_sns_topic_subscription" "cas-2-domain-events-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.cas-2-domain-events-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "offender-management.handover.changed",
      "offender-management.allocation.changed"
    ]
  })
}

module "cas-2-domain-events-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "cas-2-domain-events-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cas-2-domain-events-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "cas-2-domain-events"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "cas-2-domain-events-queue-policy" {
  queue_url = module.cas-2-domain-events-queue.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

module "cas-2-domain-events-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "cas-2-domain-events-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  business_unit          = var.business_unit
  application            = "cas-2-domain-events"
  is_production          = var.is_production
  team_name              = var.team_name # also used as queue name prefix
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "cas-2-domain-events-dlq-policy" {
  queue_url = module.cas-2-domain-events-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

resource "kubernetes_secret" "cas-2-domain-events-queue-secret" {
  metadata {
    name      = "cas-2-domain-events-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.cas-2-domain-events-queue.sqs_name
  }
}

resource "kubernetes_secret" "cas-2-domain-events-dlq-secret" {
  metadata {
    name      = "cas-2-domain-events-dlq"
    namespace = var.namespace
  }

  data = {
    QUEUE_NAME = module.cas-2-domain-events-queue.sqs_name
  }
}
