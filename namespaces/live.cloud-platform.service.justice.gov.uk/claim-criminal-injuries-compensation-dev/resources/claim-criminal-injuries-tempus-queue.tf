module "claim-criminal-injuries-tempus-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.1"

  sqs_name               = "claim-criminal-injuries-tempus-queue"
  fifo_queue             = false
  team_name              = var.team_name
  business-unit          = var.business_unit
  tempus            = var.tempus
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.claim-criminal-injuries-tempus-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "true"

  providers = {
    aws = aws.london
  }
}

data "aws_ssm_parameter" "cica_dev_account_id" {
  name = "/claim-criminal-injuries-compensation-dev/cica-dev-account-id"
}

resource "aws_sqs_queue_policy" "claim-criminal-injuries-tempus-queue-policy" {
  queue_url = module.claim-criminal-injuries-tempus-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-tempus-queue-access-policy",
    "Statement": [
      {
        "Sid": "claim-criminal-injuries-tempus-queue-allow-dcs",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": "sqs:SendMessage",
        "Resource": "${module.claim-criminal-injuries-tempus-queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": [
              "${aws_iam_user.app_service.arn}",
              "${aws_iam_user.redrive_service.arn}"
            ]
          }
        }
      },
      {
        "Sid": "claim-criminal-injuries-tempus-queue-allow-app-service",
        "Effect": "Allow",
        "Principal": {"AWS": "${data.aws_ssm_parameter.cica_dev_acct_id.value}"},
        "Action": [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": "${module.claim-criminal-injuries-tempus-queue.sqs_arn}",
      },
      {
        "Sid": "AlwaysEncrypted",
        "Effect": "Deny",
        "Principal": {"AWS": "*"},
        "Action": "sqs:*",
        "Resource": "${module.claim-criminal-injuries-tempus-queue.sqs_arn}",
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


module "claim-criminal-injuries-tempus-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name               = "claim-criminal-injuries-tempus-dead-letter-queue"
  fifo_queue             = false
  team_name              = var.team_name
  business-unit          = var.business_unit
  tempus            = var.tempus
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

resource "aws_sqs_queue_policy" "claim-criminal-injuries-tempus-dlq-policy" {
  queue_url = module.claim-criminal-injuries-tempus-dlq.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "claim-criminal-injuries-tempus-queue-dlq-policy",
    "Statement": [
      {
        "Sid": "claim-criminal-injuries-tempus-dlq-allow-redrive-service",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": [
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        "Resource": "${module.claim-criminal-injuries-tempus-dlq.sqs_arn}",
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
        "Resource": "${module.claim-criminal-injuries-tempus-dlq.sqs_arn}",
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

resource "kubernetes_secret" "claim-criminal-injuries-tempus-sqs" {
  metadata {
    name      = "tempus-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.claim-criminal-injuries-tempus-queue.access_key_id
    secret_access_key = module.claim-criminal-injuries-tempus-queue.secret_access_key
    sqs_id            = module.claim-criminal-injuries-tempus-queue.sqs_id
    sqs_arn           = module.claim-criminal-injuries-tempus-queue.sqs_arn
    sqs_name          = module.claim-criminal-injuries-tempus-queue.sqs_name
  }
}

resource "kubernetes_secret" "claim-criminal-injuries-tempus-dlq" {
  metadata {
    name      = "tempus-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.claim-criminal-injuries-tempus-dlq.access_key_id
    secret_access_key = module.claim-criminal-injuries-tempus-dlq.secret_access_key
    sqs_id            = module.claim-criminal-injuries-tempus-dlq.sqs_id
    sqs_arn           = module.claim-criminal-injuries-tempus-dlq.sqs_arn
    sqs_name          = module.claim-criminal-injuries-tempus-dlq.sqs_name
  }
}
