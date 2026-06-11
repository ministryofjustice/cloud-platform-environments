# Inbound domain-events queue (+ DLQ) for hmpps-prisoner-property-api.
# Subscribes to the shared hmpps-domain-events SNS topic and is consumed by the app's
# PrisonerEventListener. Modelled on the namespace's existing resources/sqs.tf
# (prisoner-event-queue). data.aws_ssm_parameter.hmpps-domain-events-topic-arn is already
# declared in hmpps-events.tf in this folder, so it is reused here.

resource "aws_sns_topic_subscription" "prisoner_property_event_queue_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_property_event_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received",
    ]
  })
}

module "prisoner_property_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "prisoner-property-event-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600 # 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_property_event_dlq.sqs_arn
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

module "prisoner_property_event_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "prisoner-property-event-dlq"
  encrypt_sqs_kms = "true"

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

# Allow the domain-events topic to send messages to the queue.
data "aws_iam_policy_document" "prisoner_property_event_queue" {
  policy_id = "${module.prisoner_property_event_queue.sqs_arn}/SQSDefaultPolicy"

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [module.prisoner_property_event_queue.sqs_arn]
    actions   = ["SQS:SendMessage"]
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value]
    }
  }
}

resource "aws_sqs_queue_policy" "prisoner_property_event_queue" {
  queue_url = module.prisoner_property_event_queue.sqs_id
  policy    = data.aws_iam_policy_document.prisoner_property_event_queue.json
}

resource "kubernetes_secret" "prisoner_property_event_queue" {
  metadata {
    name      = "sqs-prisoner-property-event-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_property_event_queue.sqs_id
    sqs_queue_arn  = module.prisoner_property_event_queue.sqs_arn
    sqs_queue_name = module.prisoner_property_event_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_property_event_dlq" {
  metadata {
    name      = "sqs-prisoner-property-event-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_property_event_dlq.sqs_id
    sqs_queue_arn  = module.prisoner_property_event_dlq.sqs_arn
    sqs_queue_name = module.prisoner_property_event_dlq.sqs_name
  }
}
