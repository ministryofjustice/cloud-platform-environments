resource "aws_sns_topic_subscription" "queue-subscription" {
  
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "probation-case.merge.completed",
      "probation-case.unmerge.completed",
      "probation-case.sentence.moved",
      "probation-case.deleted.gdpr"
    ]
  })
}

module "queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "hmpps-suicide-risk-form-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.dead-letter-queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

data "aws_iam_policy_document" "sns_to_sqs" {
  statement {
    sid     = "DomainEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.hmpps-domain-events.arn]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "queue-policy" {
  queue_url = module.queue.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

module "dead-letter-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps-suicide-risk-form-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "kubernetes_secret" "queue-secret" {
  metadata {
    namespace = var.namespace
    name      = "sqs-queue"
  }
  data = {
    sqs_queue_url  = module.queue.sqs_id
    sqs_queue_arn  = module.queue.sqs_arn
    sqs_queue_name = module.queue.sqs_name
  }
}

resource "kubernetes_secret" "dlq-secret" {
  metadata {
    namespace = var.namespace
    name      = "sqs-dlq"
  }
  data = {
    sqs_queue_url  = module.dead-letter-queue.sqs_id
    sqs_queue_arn  = module.dead-letter-queue.sqs_arn
    sqs_queue_name = module.dead-letter-queue.sqs_name
  }
}
