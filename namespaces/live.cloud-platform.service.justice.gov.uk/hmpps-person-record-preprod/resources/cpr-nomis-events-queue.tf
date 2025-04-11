resource "aws_sns_topic_subscription" "cpr_nomis_events_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cpr_nomis_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prisoner-offender-search.prisoner.created",
      "prisoner-offender-search.prisoner.updated",
    ]
  })
}

module "cpr_nomis_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1"

  # Queue configuration
  sqs_name                   = "cpr_nomis_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cpr_nomis_events_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
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

data "aws_iam_policy_document" "cpr_nomis_events_sqs_queue_policy_document" {
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

resource "aws_sqs_queue_policy" "cpr_nomis_events_queue_policy" {
  queue_url = module.cpr_nomis_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.cpr_nomis_events_sqs_queue_policy_document.json
}
######## Dead letter queue

module "cpr_nomis_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1"

  # Queue configuration
  sqs_name        = "cpr_nomis_events_dlq"
  encrypt_sqs_kms = "true"

  # Tags
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

########  Secrets

resource "kubernetes_secret" "cpr_nomis_events_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-nomis-events-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_nomis_events_queue.sqs_id
    sqs_queue_arn  = module.cpr_nomis_events_queue.sqs_arn
    sqs_queue_name = module.cpr_nomis_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "cpr_nomis_events_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-nomis-events-dlq-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_nomis_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.cpr_nomis_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.cpr_nomis_events_dead_letter_queue.sqs_name
  }
}
