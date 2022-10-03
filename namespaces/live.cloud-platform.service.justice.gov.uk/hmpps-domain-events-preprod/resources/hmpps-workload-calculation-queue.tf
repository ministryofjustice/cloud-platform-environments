module "workload_calculation_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "workload_calculation_hmpps_queue"
  message_retention_seconds = 14 * 86400 # 2 weeks
  namespace                 = var.namespace
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.workload_calculation_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "workload_calculation_queue_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
  ]
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
    resources = [module.workload_calculation_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "workload_calculation_queue_policy" {
  queue_url = module.workload_calculation_queue.sqs_id
  policy    = data.aws_iam_policy_document.workload_calculation_queue_policy.json
}

module "workload_calculation_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "workload_calculation_hmpps_dlq"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "workload_calculation_dlq_policy" {
  queue_url = module.workload_calculation_dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_mgmt_common_policy_document.json
}

resource "aws_sns_topic_subscription" "workload_calculation_queue_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.workload_calculation_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "staff.available.hours.changed",
    ]
  })
}

resource "kubernetes_secret" "workload_calculation_queue_secret" {
  metadata {
    name      = "sqs-workload-calculation-queue-secret"
    namespace = "hmpps-workload-preprod"
  }

  data = {
    access_key_id     = module.workload_calculation_queue.access_key_id
    secret_access_key = module.workload_calculation_queue.secret_access_key
    sqs_queue_url     = module.workload_calculation_queue.sqs_id
    sqs_queue_arn     = module.workload_calculation_queue.sqs_arn
    sqs_queue_name    = module.workload_calculation_queue.sqs_name
  }
}

resource "kubernetes_secret" "workload_calculation_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-workload-calculation-dlq-secret"
    namespace = "hmpps-workload-preprod"
  }

  data = {
    access_key_id     = module.workload_calculation_dlq.access_key_id
    secret_access_key = module.workload_calculation_dlq.secret_access_key
    sqs_queue_url     = module.workload_calculation_dlq.sqs_id
    sqs_queue_arn     = module.workload_calculation_dlq.sqs_arn
    sqs_queue_name    = module.workload_calculation_dlq.sqs_name
  }
}

