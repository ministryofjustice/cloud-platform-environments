module "hmpps_dps_reconciliation_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_dps_reconciliation_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 21600 # 6 hours
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_dps_reconciliation_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# Policy to allow SNS -> SQS
data "aws_iam_policy_document" "sqs_queue_policy_document" {
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
      values   = [
        data.aws_ssm_parameter.offender-events-topic-arn.value,
        data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value,
      ]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "hmpps_dps_reconciliation_queue_policy" {
  queue_url = module.hmpps_dps_reconciliation_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "hmpps_dps_reconciliation_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "hmpps_dps_reconciliation_dl_queue"
  message_retention_seconds  = 21600 # 6 hours
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_dps_reconciliation_queue" {
  metadata {
    name      = "hmpps-dps-reconciliation-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.hmpps_dps_reconciliation_queue.sqs_id
    sqs_arn  = module.hmpps_dps_reconciliation_queue.sqs_arn
    sqs_name = module.hmpps_dps_reconciliation_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_dps_reconciliation_dead_letter_queue" {
  metadata {
    name      = "hmpps-dps-reconciliation-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.hmpps_dps_reconciliation_dead_letter_queue.sqs_id
    sqs_arn  = module.hmpps_dps_reconciliation_dead_letter_queue.sqs_arn
    sqs_name = module.hmpps_dps_reconciliation_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_dps_reconciliation_offender_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_dps_reconciliation_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "EXTERNAL_MOVEMENT_RECORD-INSERTED",
      "EXTERNAL_MOVEMENT-CHANGED",
      "BOOKING_NUMBER-CHANGED"
    ]
  })
}

resource "aws_sns_topic_subscription" "hmpps_dps_reconciliation_domain_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_dps_reconciliation_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prisoner-offender-search.prisoner.received",
      "prisoner-offender-search.prisoner.released"
    ]
  })
}
