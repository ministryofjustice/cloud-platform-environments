module "workload_prisoner_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "workload_prisoner_hmpps_queue"
  message_retention_seconds = 14 * 86400 # 2 weeks
  namespace                 = var.namespace
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.workload_prisoner_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "workload_prisoner_queue_policy" {
  statement {
    sid     = "TopicToQueue"
    effect  = "Allow"
    actions = ["SQS:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.hmpps-domain-events.topic_arn]
    }
    resources = [module.workload_prisoner_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "workload_prisoner_queue_policy" {
  queue_url = module.workload_prisoner_queue.sqs_id
  policy    = data.aws_iam_policy_document.workload_prisoner_queue_policy.json
}

module "workload_prisoner_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "workload_prisoner_hmpps_dlq"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sns_topic_subscription" "workload_prisoner_queue_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.workload_prisoner_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received"
    ]
  })
}

resource "kubernetes_secret" "workload_prisoner_queue_secret" {
  metadata {
    name      = "hmpps-workload-prisoner-sqs-instance-output"
    namespace = "hmpps-workload-prod"
  }

  data = {
    access_key_id     = module.workload_prisoner_queue.access_key_id
    secret_access_key = module.workload_prisoner_queue.secret_access_key
    sqs_queue_url     = module.workload_prisoner_queue.sqs_id
    sqs_queue_arn     = module.workload_prisoner_queue.sqs_arn
    sqs_queue_name    = module.workload_prisoner_queue.sqs_name
  }
}

resource "kubernetes_secret" "workload_prisoner_dead_letter_queue_secret" {
  metadata {
    name      = "hmpps-workload-prisoner-sqs-dl-instance-output"
    namespace = "hmpps-workload-prod"
  }

  data = {
    access_key_id     = module.workload_prisoner_dlq.access_key_id
    secret_access_key = module.workload_prisoner_dlq.secret_access_key
    sqs_queue_url     = module.workload_prisoner_dlq.sqs_id
    sqs_queue_arn     = module.workload_prisoner_dlq.sqs_arn
    sqs_queue_name    = module.workload_prisoner_dlq.sqs_name
  }
}

