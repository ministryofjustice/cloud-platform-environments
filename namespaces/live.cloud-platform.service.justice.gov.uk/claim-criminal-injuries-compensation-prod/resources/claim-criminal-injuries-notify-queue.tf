module "claim-criminal-injuries-notify-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name   = "claim-criminal-injuries-notify-queue"
  fifo_queue = false

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.claim-criminal-injuries-notify-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "claim-criminal-injuries-notify-queue-policy" {
  queue_url = module.claim-criminal-injuries-notify-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-notify-queue-access-policy",
    "Statement": [
      {
        "Sid": "claim-criminal-injuries-notify-queue-allow-dcs",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": "sqs:SendMessage",
        "Resource": "${module.claim-criminal-injuries-notify-queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${module.irsa-dcs.role_arn}"
          }
        }
      },
      {
        "Sid": "claim-criminal-injuries-notify-queue-allow-notify-gateway",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": "${module.claim-criminal-injuries-notify-queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${module.irsa-notifyservice.role_arn}"
          }
        }
      },
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": {"AWS": "*"},
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-notify-queue.sqs_arn}",
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  }
  EOF
}


module "claim-criminal-injuries-notify-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name   = "claim-criminal-injuries-notify-dead-letter-queue"
  fifo_queue = false

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "claim-criminal-injuries-notify-dlq-policy" {
  queue_url = module.claim-criminal-injuries-notify-dlq.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-notify-queue-dlq-policy",
    "Statement": [
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": {"AWS": "*"},
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-notify-dlq.sqs_arn}",
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  }
  EOF
}

resource "kubernetes_secret" "claim-criminal-injuries-notify-sqs" {
  metadata {
    name      = "notify-sqs"
    namespace = var.namespace
  }

  data = {
    sqs_id            = module.claim-criminal-injuries-notify-queue.sqs_id
    sqs_arn           = module.claim-criminal-injuries-notify-queue.sqs_arn
    sqs_name          = module.claim-criminal-injuries-notify-queue.sqs_name
  }
}

resource "kubernetes_secret" "claim-criminal-injuries-notify-dlq" {
  metadata {
    name      = "notify-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_id            = module.claim-criminal-injuries-notify-dlq.sqs_id
    sqs_arn           = module.claim-criminal-injuries-notify-dlq.sqs_arn
    sqs_name          = module.claim-criminal-injuries-notify-dlq.sqs_name
  }
}
