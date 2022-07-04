module "workforce_allocation_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.7"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "workforce_allocation_hmpps_queue"
  message_retention_seconds = 14 * 86400 # 2 weeks
  namespace                 = var.namespace
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.workforce_allocation_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

module "workforce_allocation_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.7"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "workforce_allocation_hmpps_dlq"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "workforce_allocation_queue_policy" {
  statement {
    sid     = "SendMessagesFromTopic"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.hmpps-domain-events.topic_arn]
    }
    resources = [module.workforce_allocation_queue.sqs_arn]
  }
  statement {
    sid    = "ReceiveMessagesFromDelius"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::010587221707:role/delius-pre-prod-sqs-consumer"
      ]
    }
    resources = [module.workforce_allocation_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "workforce_allocation_queue_policy" {
  queue_url = module.workforce_allocation_queue.sqs_id
  policy    = data.aws_iam_policy_document.workforce_allocation_queue_policy.json
}

resource "aws_sns_topic_subscription" "workforce_allocation_queue_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.workforce_allocation_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "person.community.manager.allocated",
      "event.manager.allocated",
      "requirement.manager.allocated",
    ]
  })
}

resource "kubernetes_secret" "workforce_allocation_queue_secret" {
  metadata {
    name      = "sqs-workforce-allocation-queue-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.workforce_allocation_queue.access_key_id
    secret_access_key = module.workforce_allocation_queue.secret_access_key
    sqs_queue_url     = module.workforce_allocation_queue.sqs_id
    sqs_queue_arn     = module.workforce_allocation_queue.sqs_arn
    sqs_queue_name    = module.workforce_allocation_queue.sqs_name
  }
}

resource "kubernetes_secret" "workforce_allocation_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-workforce-allocation-dlq-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.workforce_allocation_dlq.access_key_id
    secret_access_key = module.workforce_allocation_dlq.secret_access_key
    sqs_queue_url     = module.workforce_allocation_dlq.sqs_id
    sqs_queue_arn     = module.workforce_allocation_dlq.sqs_arn
    sqs_queue_name    = module.workforce_allocation_dlq.sqs_name
  }
}
