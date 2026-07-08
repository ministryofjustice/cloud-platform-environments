resource "aws_sns_topic_subscription" "cpr_delius_address_events_from_cpr_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cpr_delius_address_events_from_cpr_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "probation-case.address.created",
    ],
    eventSource = [
      "core-person-record"
    ]
  })
}

module "cpr_delius_address_events_from_cpr_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"
  
  sqs_name                   = "cpr_delius_address_events_from_cpr_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cpr_delius_address_events_from_cpr_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
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

data "aws_iam_policy_document" "cpr_delius_address_events_from_cpr_policy_document" {
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
      values   = [data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "cpr_delius_address_events_from_cpr_queue_policy" {
  queue_url = module.cpr_delius_address_events_from_cpr_queue.sqs_id
  policy    = data.aws_iam_policy_document.cpr_delius_address_events_from_cpr_policy_document.json
}

######## Dead letter queue

module "cpr_delius_address_events_from_cpr_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"
  
  sqs_name        = "cpr_delius_address_events_from_cpr_dlq"
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

resource "kubernetes_secret" "cpr_delius_address_events_from_cpr_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-delius-address-events-from-cpr-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_delius_address_events_from_cpr_queue.sqs_id
    sqs_queue_arn  = module.cpr_delius_address_events_from_cpr_queue.sqs_arn
    sqs_queue_name = module.cpr_delius_address_events_from_cpr_queue.sqs_name
  }
}

resource "kubernetes_secret" "cpr_delius_address_events_from_cpr_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-delius-address-events-from-cpr-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_delius_address_events_from_cpr_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.cpr_delius_address_events_from_cpr_dead_letter_queue.sqs_arn
    sqs_queue_name = module.cpr_delius_address_events_from_cpr_dead_letter_queue.sqs_name
  }
}
