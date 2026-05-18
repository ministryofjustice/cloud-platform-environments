# Claims events SNS topic ARN, exported by laa-data-claims-api-uat.
data "aws_ssm_parameter" "claims_sns_topic_arn" {
  name = "/${var.producer_namespace}/topic-arn"
}

module "notify_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "claims-notify-queue"
  encrypt_sqs_kms           = true
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.notify_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "notify_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "claims-notify-queue-dlq"
  encrypt_sqs_kms = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# Only the claims events SNS topic may send to the notify queue.
data "aws_iam_policy_document" "notify_queue" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [module.notify_queue.sqs_arn]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [data.aws_ssm_parameter.claims_sns_topic_arn.value]
    }
  }
}

resource "aws_sqs_queue_policy" "notify_queue" {
  queue_url = module.notify_queue.sqs_id
  policy    = data.aws_iam_policy_document.notify_queue.json
}

resource "aws_sns_topic_subscription" "notify" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.claims_sns_topic_arn.value
  protocol  = "sqs"
  endpoint  = module.notify_queue.sqs_arn

  filter_policy = jsonencode({
    SubmissionEventType = ["SUBMISSION_VALIDATION_SUCCEEDED"]
  })
}

resource "kubernetes_secret" "notify_queue" {
  metadata {
    name      = "sqs-claims-notify-queue-secret"
    namespace = var.namespace
  }
  data = {
    sqs_queue_url  = module.notify_queue.sqs_id
    sqs_queue_arn  = module.notify_queue.sqs_arn
    sqs_queue_name = module.notify_queue.sqs_name
  }
}

resource "kubernetes_secret" "notify_dlq" {
  metadata {
    name      = "sqs-claims-notify-queue-dlq-secret"
    namespace = var.namespace
  }
  data = {
    sqs_queue_url  = module.notify_dlq.sqs_id
    sqs_queue_arn  = module.notify_dlq.sqs_arn
    sqs_queue_name = module.notify_dlq.sqs_name
  }
}
