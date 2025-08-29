# SNS Topics

module "sns_topic_file_upload" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name = "${var.namespace}-file-upload-sns"

  encrypt_sns_kms             = true
  fifo_topic                  = false
  content_based_deduplication = false

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace
}

module "sns_topic_person_id" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name = "${var.namespace}-person-id-sns"

  encrypt_sns_kms             = true
  fifo_topic                  = false
  content_based_deduplication = false

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace
}

# SQS Queues

resource "aws_sqs_queue" "file_upload_queue" {
  name                       = "${var.namespace}-file-upload-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
}

resource "aws_sqs_queue" "person_id_queue" {
  name                       = "${var.namespace}-person-id-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
}

# SNS → SQS Subscriptions

resource "aws_sns_topic_subscription" "file_upload_sqs" {
  topic_arn = module.sns_topic_file_upload.topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.file_upload_queue.arn
}

resource "aws_sns_topic_subscription" "person_id_sqs" {
  topic_arn = module.sns_topic_person_id.topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.person_id_queue.arn
}

# Queue Policies (allow SNS to publish to SQS)

resource "aws_sqs_queue_policy" "file_upload_policy" {
  queue_url = aws_sqs_queue.file_upload_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.file_upload_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.sns_topic_file_upload.topic_arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "person_id_policy" {
  queue_url = aws_sqs_queue.person_id_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.person_id_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.sns_topic_person_id.topic_arn
          }
        }
      }
    ]
  })
}

# Kubernetes Secrets (expose SNS + SQS info to workloads)

resource "kubernetes_secret" "file_upload_sns" {
  metadata {
    name      = "file-upload-sns-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.sns_topic_file_upload.topic_arn
  }
}

resource "kubernetes_secret" "file_upload_sqs" {
  metadata {
    name      = "file-upload-sqs"
    namespace = var.namespace
  }
  data = {
    queue_url = aws_sqs_queue.file_upload_queue.id
    queue_arn = aws_sqs_queue.file_upload_queue.arn
  }
}

resource "kubernetes_secret" "person_id_sns" {
  metadata {
    name      = "person-id-sns-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.sns_topic_person_id.topic_arn
  }
}

resource "kubernetes_secret" "person_id_sqs" {
  metadata {
    name      = "person-id-sqs"
    namespace = var.namespace
  }
  data = {
    queue_url = aws_sqs_queue.person_id_queue.id
    queue_arn = aws_sqs_queue.person_id_queue.arn
  }
}

# IAM Policies for IRSA (SQS Consumer Permissions)

resource "aws_iam_policy" "file_upload_sqs_irsa" {
  name        = "${var.namespace}-file-upload-sqs-irsa"
  description = "Allow IRSA role to consume messages from file-upload queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.file_upload_queue.arn
      }
    ]
  })
}

resource "aws_iam_policy" "person_id_sqs_irsa" {
  name        = "${var.namespace}-person-id-sqs-irsa"
  description = "Allow IRSA role to consume messages from person-id queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.person_id_queue.arn
      }
    ]
  })
}

# Outputs for IRSA

output "file_upload_sqs_irsa_policy_arn" {
  description = "IAM policy ARN that grants IRSA permissions to consume messages from the file-upload SQS queue"
  value       = aws_iam_policy.file_upload_sqs_irsa.arn
}

output "person_id_sqs_irsa_policy_arn" {
  description = "IAM policy ARN that grants IRSA permissions to consume messages from the person-id SQS queue"
  value       = aws_iam_policy.person_id_sqs_irsa.arn
}