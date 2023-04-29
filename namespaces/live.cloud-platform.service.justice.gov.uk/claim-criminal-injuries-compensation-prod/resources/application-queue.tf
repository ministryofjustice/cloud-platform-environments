module "claim-criminal-injuries-application-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name               = "claim-criminal-injuries-application-queue"
  fifo_queue             = false
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.claim-criminal-injuries-application-dlq.sqs_arn
    maxReceiveCount     = 1
  })

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "true"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "claim-criminal-injuries-application-queue-policy" {
  queue_url = module.claim-criminal-injuries-application-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-application-queue-access-policy",
    "Statement": [
      {
        "Sid": "claim-criminal-injuries-application-queue-allow-dcs",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": "sqs:SendMessage",
        "Resource": "${module.claim-criminal-injuries-application-queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": [
              "${aws_iam_user.dcs.arn}",
              "${aws_iam_user.redrive_service.arn}"
            ]
          }
        }
      },
      {
        "Sid": "claim-criminal-injuries-application-queue-allow-app-service",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": "${module.claim-criminal-injuries-application-queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": [
              "${aws_iam_user.app_service.arn}"
            ]
          }
        }
      },
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": {"AWS": "*"},
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-application-queue.sqs_arn}",
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


module "claim-criminal-injuries-application-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name               = "claim-criminal-injuries-application-dead-letter-queue"
  fifo_queue             = false
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "true"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "claim-criminal-injuries-application-dlq-policy" {
  queue_url = module.claim-criminal-injuries-application-dlq.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-application-queue-dlq-policy",
    "Statement": [
      {
        "Sid": "claim-criminal-injuries-application-dlq-allow-redrive-service",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": [
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        "Resource": "${module.claim-criminal-injuries-application-dlq.sqs_arn}",
        "Condition": {
          "ArnNotEquals": {
            "aws:SourceArn": [
              "${aws_iam_user.redrive_service.arn}"
            ]
          }
        }
      },
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": {"AWS": "*"},
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-application-dlq.sqs_arn}",
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

resource "kubernetes_secret" "claim-criminal-injuries-application-sqs" {
  metadata {
    name      = "application-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.claim-criminal-injuries-application-queue.access_key_id
    secret_access_key = module.claim-criminal-injuries-application-queue.secret_access_key
    sqs_id            = module.claim-criminal-injuries-application-queue.sqs_id
    sqs_arn           = module.claim-criminal-injuries-application-queue.sqs_arn
    sqs_name          = module.claim-criminal-injuries-application-queue.sqs_name
  }
}

resource "kubernetes_secret" "claim-criminal-injuries-application-dlq" {
  metadata {
    name      = "application-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.claim-criminal-injuries-application-dlq.access_key_id
    secret_access_key = module.claim-criminal-injuries-application-dlq.secret_access_key
    sqs_id            = module.claim-criminal-injuries-application-dlq.sqs_id
    sqs_arn           = module.claim-criminal-injuries-application-dlq.sqs_arn
    sqs_name          = module.claim-criminal-injuries-application-dlq.sqs_name
  }
}
