module "hmpps_pfs_web_analytics_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_pfs_web_analytics_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 12 * 60 * 60 # 12h

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_pfs_web_analytics_dlq.sqs_arn}","maxReceiveCount": 3
  }

EOF

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


module "hmpps_pfs_web_analytics_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_pfs_web_analytics_dlq"
  encrypt_sqs_kms = "true"
  message_retention_seconds = 24 * 60 * 60  # 1d

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

# Secrets

resource "kubernetes_secret" "hmpps_pfs_web_analytics_queue_secret" {
  metadata {
    name      = "sqs-analytics-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_pfs_web_analytics_queue.sqs_id
    sqs_queue_arn  = module.hmpps_pfs_web_analytics_queue.sqs_arn
    sqs_queue_name = module.hmpps_pfs_web_analytics_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_pfs_web_analytics_dlq_secret" {
  metadata {
    name      = "sqs-analytics-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_pfs_web_analytics_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_pfs_web_analytics_dlq.sqs_arn
    sqs_queue_name = module.hmpps_pfs_web_analytics_dlq.sqs_name
  }
}

# Subscribe SQS to SNS Analytics and SNS Common

resource "aws_sns_topic_subscription" "common_analytics_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-pfs-common.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps_pfs_web_analytics_queue.sqs_arn
}

resource "aws_sns_topic_subscription" "analytics_only_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-pfs-analytics.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps_pfs_web_analytics_queue.sqs_arn
}

# IAM Policies
data "aws_iam_policy_document" "hmpps_pfs_web_analytics_queue_policy" {
  policy_id = module.hmpps_pfs_web_analytics_queue.sqs_arn

  # Allow Web Analytics SNS and Common SNS to send messages
  statement {
    sid    = "AllowWebAnalyticsQueueSend"
    effect = "Allow"

    actions   = ["sqs:SendMessage"]
    resources = [module.hmpps_pfs_web_analytics_queue.sqs_arn]

    principals {
      type        = "AWS"
      identifiers = [
        module.hmpps-pfs-common.topic_arn,
        module.hmpps-pfs-analytics.topic_arn
      ]
    }
  }

  # Allow service account to manage queue
  statement {
    sid    = "AllowWebAnalyticsQueueManage"
    effect = "Allow"

    actions   = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
    ]
    resources = [module.hmpps_pfs_web_analytics_queue.sqs_arn]

    principals {
      type        = "AWS"
      identifiers = [module.hmpps_pfs_web_analytics_irsa.role_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "hmpps_pfs_web_analytics_queue_policy" {
  queue_url = module.hmpps_pfs_web_analytics_queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps_pfs_web_analytics_queue_policy.json
}