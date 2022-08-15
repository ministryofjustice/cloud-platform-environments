module "case_note_poll_pusher_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "case_note_poll_pusher_queue"
  encrypt_sqs_kms           = "true"
  kms_external_access       = ["arn:aws:iam::010587221707:role/delius-pre-prod-ecs-sqs-consumer"]
  message_retention_seconds = 1209600 # 2 weeks
  namespace                 = var.namespace
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.case_note_poll_pusher_dead_letter_queue.sqs_arn,
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "case_note_poll_pusher_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.sqs_mgmt_common_policy_document[module.case_note_poll_pusher_queue.sqs_arn].json
  ]
  statement {
    sid    = "TopicToQueue"
    effect = "Allow"
    actions = [
      "SQS:SendMessage"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.offender_events.topic_arn]
    }
    resources = [module.case_note_poll_pusher_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "case_note_poll_pusher_queue_policy" {
  queue_url = module.case_note_poll_pusher_queue.sqs_id
  policy    = data.aws_iam_policy_document.case_note_poll_pusher_policy.json
}

module "case_note_poll_pusher_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "case_note_poll_pusher_queue_dl"
  encrypt_sqs_kms           = "true"
  kms_external_access       = ["arn:aws:iam::010587221707:role/delius-pre-prod-ecs-sqs-consumer"]
  message_retention_seconds = 1209600 # 2 weeks
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "case_note_poll_pusher_dead_letter_queue_policy" {
  queue_url = module.case_note_poll_pusher_dead_letter_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document[module.case_note_poll_pusher_dead_letter_queue.sqs_arn].json
}

resource "aws_sns_topic_subscription" "case_note_poll_pusher_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.case_note_poll_pusher_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "PRISON-RELEASE",
      "TRANSFER-FROMTOL",
      "GEN-OSE",
      "ALERT-ACTIVE",
      "ALERT-INACTIVE",
      { prefix = "OMIC" },
      { prefix = "OMIC_OPD" },
      { prefix = "KA" }
    ]
  })
}
