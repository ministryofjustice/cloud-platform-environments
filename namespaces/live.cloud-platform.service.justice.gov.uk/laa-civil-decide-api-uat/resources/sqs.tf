# Data Access events SNS topic ARN, exported by laa-data-access-api-uat.
data "aws_ssm_parameter" "data_access_events_sns_topic_arn" {
  name = "/${var.producer_namespace}/topic-arn"
}

module "application_submitted_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                   = "application-submitted-queue"
  encrypt_sqs_kms            = true
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.application_submitted_dlq.sqs_arn
    maxReceiveCount     = 5
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  github_team            = var.github_team

  providers = {
    aws = aws.london
  }
}

module "application_submitted_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "application-submitted-queue-dlq"
  encrypt_sqs_kms           = true
  message_retention_seconds = 1209600

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  github_team            = var.github_team

  providers = {
    aws = aws.london
  }
}

# Only the Data Access Application Submitted topic may send to this queue.
data "aws_iam_policy_document" "application_submitted_queue" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [module.application_submitted_queue.sqs_arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [data.aws_ssm_parameter.data_access_events_sns_topic_arn.value]
    }
  }
}

resource "aws_sqs_queue_policy" "application_submitted_queue" {
  queue_url = module.application_submitted_queue.sqs_id
  policy    = data.aws_iam_policy_document.application_submitted_queue.json
}

data "aws_iam_policy_document" "application_submitted_consumer" {
  statement {
    sid    = "ConsumeApplicationSubmittedMessages"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
    ]
    resources = [module.application_submitted_queue.sqs_arn]
  }

  statement {
    sid    = "InspectApplicationSubmittedDeadLetters"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
    ]
    resources = [module.application_submitted_dlq.sqs_arn]
  }
}

resource "aws_iam_policy" "application_submitted_consumer" {
  name        = "${var.namespace}-application-submitted-consumer"
  description = "Allows Civil Decide to consume Application Submitted messages and inspect the DLQ"
  policy      = data.aws_iam_policy_document.application_submitted_consumer.json
}

resource "aws_sns_topic_subscription" "application_submitted" {
  provider            = aws.london
  topic_arn           = data.aws_ssm_parameter.data_access_events_sns_topic_arn.value
  protocol            = "sqs"
  endpoint            = module.application_submitted_queue.sqs_arn
  filter_policy_scope = "MessageBody"

  filter_policy = jsonencode({
    eventType = ["ApplicationSubmitted"]
  })
}

resource "kubernetes_secret" "application_submitted_queue" {
  metadata {
    name      = "sqs-application-submitted-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.application_submitted_queue.sqs_id
    sqs_queue_arn  = module.application_submitted_queue.sqs_arn
    sqs_queue_name = module.application_submitted_queue.sqs_name
  }
}

resource "kubernetes_secret" "application_submitted_dlq" {
  metadata {
    name      = "sqs-application-submitted-queue-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.application_submitted_dlq.sqs_id
    sqs_queue_arn  = module.application_submitted_dlq.sqs_arn
    sqs_queue_name = module.application_submitted_dlq.sqs_name
  }
}
