module "prisoner_schedules_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  # Queue configuration
  sqs_name                  = "domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 7 * 24 * 3600 # 1 week
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn: module.prisoner_schedules_domain_events_dlq.sqs_arn
    maxReceiveCount: 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-prisoner-schedules" # Hard coded as prefix in queue names
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "prisoner_schedules_domain_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  # Queue configuration
  sqs_name        = "domain_events_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-prisoner-schedules" # Hard coded as used as prefix in queue names
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "sqs_queue_policy_document" {
  policy_id = "${module.prisoner_schedules_domain_events_queue.sqs_arn}/SQSDefaultPolicy"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [module.prisoner_schedules_domain_events_queue.sqs_arn]
    actions   = ["SQS:SendMessage"]
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value]
    }
  }
}

resource "aws_sqs_queue_policy" "prisoner_schedules_domain_event_queue_policy" {
  queue_url = module.prisoner_schedules_domain_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "aws_sns_topic_subscription" "prisoner_schedules_domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_schedules_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prisoner-offender-search.prisoner.released",
      "prisoner-offender-search.prisoner.received",
      "prison-offender-events.prisoner.merged",
      "prison-offender-events.prisoner.booking.moved",
      "prison-offender-events.prisoner.booking.deleted",
      "official-visits-api.visit.created",
      "official-visits-api.visit.updated",
      "official-visits-api.visit.cancelled",
      "official-visits-api.visit.deleted",
    ]
  })
}

resource "kubernetes_secret" "prisoner_schedules_domain_events_queue" {
  metadata {
    name      = "sqs-domain-events-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id                        = module.prisoner_schedules_domain_events_queue.sqs_id
    sqs_arn                       = module.prisoner_schedules_domain_events_queue.sqs_arn
    sqs_name                      = module.prisoner_schedules_domain_events_queue.sqs_name
    hmpps_domain_events_topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value

  }
}

resource "kubernetes_secret" "prisoner_schedules_domain_events_dlq" {
  metadata {
    name      = "sqs-domain-events-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_schedules_domain_events_dlq.sqs_id
    sqs_arn  = module.prisoner_schedules_domain_events_dlq.sqs_arn
    sqs_name = module.prisoner_schedules_domain_events_dlq.sqs_name
  }
}
