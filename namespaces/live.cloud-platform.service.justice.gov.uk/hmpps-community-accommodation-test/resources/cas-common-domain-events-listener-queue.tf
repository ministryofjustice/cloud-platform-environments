resource "aws_sns_topic_subscription" "cas-common-domain-events-listener-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.cas-common-domain-events-listener-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "tier.calculation.complete"
    ]
  })
}

module "cas-common-domain-events-listener-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "cas-common-domain-events-listener-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cas-common-domain-events-listener-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "cas-common-domain-events-listener"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "cas-common-domain-events-listener-queue-policy" {
  queue_url = module.cas-common-domain-events-listener-queue.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

module "cas-common-domain-events-listener-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "cas-common-domain-events-listener-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  business_unit          = var.business_unit
  application            = "cas-common-domain-events-listener"
  is_production          = var.is_production
  team_name              = var.team_name # also used as queue name prefix
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "cas-common-domain-events-listener-dlq-policy" {
  queue_url = module.cas-common-domain-events-listener-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

resource "kubernetes_secret" "cas-common-domain-events-listener-queue-secret" {
  metadata {
    name      = "cas-common-domain-events-listener-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.cas-common-domain-events-listener-queue.sqs_name
  }
}

resource "kubernetes_secret" "cas-common-domain-events-listener-dlq-secret" {
  metadata {
    name      = "cas-common-domain-events-listener-dlq"
    namespace = var.namespace
  }

  data = {
    QUEUE_NAME = module.cas-common-domain-events-listener-dlq.sqs_name
  }
}
