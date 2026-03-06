module "claim-criminal-injuries-letter-queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name   = "claim-criminal-injuries-letter-queue"
  fifo_queue = false

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.claim-criminal-injuries-letter-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms     = "true"
  kms_external_access = [data.aws_ssm_parameter.cica_dev_account_id.value]

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

resource "aws_sqs_queue_policy" "claim-criminal-injuries-letter-queue-policy" {
  queue_url = module.claim-criminal-injuries-letter-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-letter-queue-access-policy",
    "Statement": [
      {
        "Sid": "claim-criminal-injuries-letter-queue-allow-letter-service",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": "${module.claim-criminal-injuries-letter-queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${module.irsa-letter-service.role_arn}"
          }
        }
      },
      {
        "Sid": "claim-criminal-injuries-letter-queue-allow-tempus-letter-broker",
        "Effect": "Allow",
        "Principal": {"AWS": "${data.aws_ssm_parameter.cica_dev_account_id.value}"},
        "Action": "sqs:SendMessage",
        "Resource": "${module.claim-criminal-injuries-letter-queue.sqs_arn}"
      },
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-letter-queue.sqs_arn}",
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

module "claim-criminal-injuries-letter-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name   = "claim-criminal-injuries-letter-dlq"
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

resource "aws_sqs_queue_policy" "claim-criminal-injuries-letter-dlq-policy" {
  queue_url = module.claim-criminal-injuries-letter-dlq.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-letter-dlq-policy",
    "Statement": [
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": {"AWS": "*"},
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-letter-dlq.sqs_arn}",
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

resource "kubernetes_secret" "claim-criminal-injuries-letter-sqs" {
  metadata {
    name      = "cica-letter-sqs"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.claim-criminal-injuries-letter-queue.sqs_id
    sqs_arn  = module.claim-criminal-injuries-letter-queue.sqs_arn
    sqs_name = module.claim-criminal-injuries-letter-queue.sqs_name
  }
}

resource "kubernetes_secret" "claim-criminal-injuries-letter-dlq" {
  metadata {
    name      = "cica-letter-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.claim-criminal-injuries-letter-dlq.sqs_id
    sqs_arn  = module.claim-criminal-injuries-letter-dlq.sqs_arn
    sqs_name = module.claim-criminal-injuries-letter-dlq.sqs_name
  }
}
