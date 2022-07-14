module "case_note_poll_pusher_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "case_note_poll_pusher_queue"
  encrypt_sqs_kms           = "true"
  kms_external_access       = ["arn:aws:iam::728765553488:role/delius-test-ecs-sqs-consumer"]
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
  version   = "2012-10-17"
  policy_id = "${module.case_note_poll_pusher_queue.sqs_arn}/SQSDefaultPolicy"
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
  statement {
    sid    = "QueueToConsumer"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::728765553488:role/delius-test-ecs-sqs-consumer"
      ]
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
  kms_external_access       = ["arn:aws:iam::728765553488:role/delius-test-ecs-sqs-consumer"]
  message_retention_seconds = 1209600 # 2 weeks
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "case_note_poll_pusher_dead_letter_queue_policy" {
  version   = "2012-10-17"
  policy_id = "${module.case_note_poll_pusher_queue.sqs_arn}/SQSDefaultPolicy"
  statement {
    sid    = "QueueToConsumer"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::728765553488:role/delius-test-ecs-sqs-consumer"
      ]
    }
    resources = [module.case_note_poll_pusher_dead_letter_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "case_note_poll_pusher_dead_letter_queue_policy" {
  queue_url = module.case_note_poll_pusher_dead_letter_queue.sqs_id
  policy    = data.aws_iam_policy_document.case_note_poll_pusher_dead_letter_queue_policy.json
}

resource "kubernetes_secret" "case_note_poll_pusher_queue" {
  metadata {
    name      = "cnpp-sqs-instance-output"
    namespace = "case-notes-to-probation-dev"
  }

  data = {
    access_key_id     = module.case_note_poll_pusher_queue.access_key_id
    secret_access_key = module.case_note_poll_pusher_queue.secret_access_key
    sqs_cnpp_url      = module.case_note_poll_pusher_queue.sqs_id
    sqs_cnpp_arn      = module.case_note_poll_pusher_queue.sqs_arn
    sqs_cnpp_name     = module.case_note_poll_pusher_queue.sqs_name
  }
}

resource "kubernetes_secret" "case_note_poll_pusher_dead_letter_queue" {
  metadata {
    name      = "cnpp-sqs-dl-instance-output"
    namespace = "case-notes-to-probation-dev"
  }

  data = {
    access_key_id     = module.case_note_poll_pusher_dead_letter_queue.access_key_id
    secret_access_key = module.case_note_poll_pusher_dead_letter_queue.secret_access_key
    sqs_cnpp_url      = module.case_note_poll_pusher_dead_letter_queue.sqs_id
    sqs_cnpp_arn      = module.case_note_poll_pusher_dead_letter_queue.sqs_arn
    sqs_cnpp_name     = module.case_note_poll_pusher_dead_letter_queue.sqs_name
  }
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

