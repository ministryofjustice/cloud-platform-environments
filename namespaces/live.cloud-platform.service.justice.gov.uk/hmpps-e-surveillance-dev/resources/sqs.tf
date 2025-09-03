# SQS Queues

module "fileupload_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "fileuploadqueue"
  encrypt_sqs_kms          = true
  message_retention_seconds = 86400

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.fileupload_dlq.sqs_arn}",
    "maxReceiveCount": 5
  }
  EOF

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
}

module "fileupload_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "fileuploadqueuedlq"
  encrypt_sqs_kms          = true
  message_retention_seconds = 1209600  # 14 days

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
}

module "personid_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "personidqueue.fifo"
  encrypt_sqs_kms          = true
  fifo_queue               = true
  message_retention_seconds = 86400

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.personid_dlq.sqs_arn}",
    "maxReceiveCount": 5
  }
  EOF

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
}

module "personid_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "personidqueuedlq.fifo"
  encrypt_sqs_kms          = true
  fifo_queue               = true
  message_retention_seconds = 1209600  # 14 days

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
}

# SNS → SQS Subscriptions

resource "aws_sns_topic_subscription" "fileupload_sqs" {
  topic_arn = module.sns_topic_fileupload.topic_arn
  protocol  = "sqs"
  endpoint  = module.fileupload_queue.sqs_arn
}

resource "aws_sns_topic_subscription" "personid_sqs" {
  topic_arn = module.sns_topic_personid.topic_arn
  protocol  = "sqs"
  endpoint  = module.personid_queue.sqs_arn
}

# Queue Policies (allow SNS to publish to SQS)

resource "aws_sqs_queue_policy" "fileupload_policy" {
  queue_url = module.fileupload_queue.sqs_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = module.fileupload_queue.sqs_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.sns_topic_fileupload.topic_arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "personid_policy" {
  queue_url = module.personid_queue.sqs_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = module.personid_queue.sqs_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.sns_topic_personid.topic_arn
          }
        }
      }
    ]
  })
}

# Kubernetes Secrets for SQS Queues

resource "kubernetes_secret" "fileupload_sqs" {
  metadata {
    name      = "sqs-fileupload-output"
    namespace = var.namespace
  }
  data = {
    queue_id   = module.fileupload_queue.sqs_id
    queue_arn  = module.fileupload_queue.sqs_arn
    queue_name = module.fileupload_queue.sqs_name
  }
}

resource "kubernetes_secret" "personid_sqs" {
  metadata {
    name      = "sqs-personid-output"
    namespace = var.namespace
  }
  data = {
    queue_id   = module.personid_queue.sqs_id
    queue_arn  = module.personid_queue.sqs_arn
    queue_name = module.personid_queue.sqs_name
  }
}

resource "kubernetes_secret" "fileupload_sqs_dlq" {
  metadata {
    name      = "sqs-fileupload-dl-output"
    namespace = var.namespace
  }
  data = {
    queue_id   = module.fileupload_dlq.sqs_id
    queue_arn  = module.fileupload_dlq.sqs_arn
    queue_name = module.fileupload_dlq.sqs_name
  }
}

resource "kubernetes_secret" "personid_sqs_dlq" {
  metadata {
    name      = "sqs-personid-dl-output"
    namespace = var.namespace
  }
  data = {
    queue_id   = module.personid_dlq.sqs_id
    queue_arn  = module.personid_dlq.sqs_arn
    queue_name = module.personid_dlq.sqs_name
  }
}

# IAM Policies for IRSA (SQS Consumer Permissions)

resource "aws_iam_policy" "fileupload_sqs_irsa" {
  name        = "${var.namespace}-fileupload-sqs-irsa"
  description = "Allow IRSA role to consume messages from fileupload queue"

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
        Resource = module.fileupload_queue.sqs_arn
      }
    ]
  })
}

resource "aws_iam_policy" "personid_sqs_irsa" {
  name        = "${var.namespace}-personid-sqs-irsa"
  description = "Allow IRSA role to consume messages from personid queue"

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
        Resource = module.personid_queue.sqs_arn
      }
    ]
  })
}

# Outputs for IRSA

output "fileupload_sqs_irsa_policy_arn" {
  description = "IAM policy ARN that grants IRSA permissions to consume messages from the fileupload SQS queue"
  value       = aws_iam_policy.fileupload_sqs_irsa.arn
}

output "personid_sqs_irsa_policy_arn" {
  description = "IAM policy ARN that grants IRSA permissions to consume messages from the personid SQS queue"
  value       = aws_iam_policy.personid_sqs_irsa.arn
}