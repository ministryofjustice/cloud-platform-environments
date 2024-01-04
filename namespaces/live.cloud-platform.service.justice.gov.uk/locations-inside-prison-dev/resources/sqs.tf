resource "aws_sns_topic_subscription" "prisoner_event_queue_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner-event-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "dummy-event-will-filter-out-all-events",
    ]
  })
}

module "prisoner-event-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  sqs_name                  = "prisoner-event-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner-event-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "sqs" {
  policy_id = "${module.prisoner-event-queue.sqs_arn}/SQSDefaultPolicy"

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [module.prisoner-event-queue.sqs_arn]
    actions   = ["SQS:SendMessage"]
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value]
    }
  }
}

resource "aws_sqs_queue_policy" "prisoner-event-queue-policy" {
  queue_url = module.prisoner-event-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs.json
}

module "prisoner-event-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  sqs_name        = "prisoner-event-dlq"
  encrypt_sqs_kms = "true"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner-event-queue" {
  metadata {
    name      = "sqs-prisoner-event-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner-event-queue.sqs_id
    sqs_queue_arn  = module.prisoner-event-queue.sqs_arn
    sqs_queue_name = module.prisoner-event-queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner-event-queue-dlq" {
  metadata {
    name      = "sqs-prisoner-event-queue-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner-event-dlq.sqs_id
    sqs_queue_arn  = module.prisoner-event-dlq.sqs_arn
    sqs_queue_name = module.prisoner-event-dlq.sqs_name
  }
}
