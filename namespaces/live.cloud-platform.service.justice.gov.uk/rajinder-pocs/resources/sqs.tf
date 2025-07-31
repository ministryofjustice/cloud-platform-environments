module "rajinder_poc_sqs_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name   = "rajinder-poc-sqs-queue"
  fifo_queue = false

  /*   redrive_policy = jsonencode({
    deadLetterTargetArn = module.claim-criminal-injuries-application-dlq.sqs_arn
    maxReceiveCount     = 3
  }) */

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "false"

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

resource "aws_sqs_queue_policy" "rajinder_poc_sqs_queue" {
  queue_url = module.rajinder_poc_sqs_queue.sqs_id
  policy    = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "rajinder-poc-queue-access-policy",
    "Statement": [
      {
        "Sid": "rajinder-poc-queue-allow-send",
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": "sqs:SendMessage",
        "Resource": "${module.rajinder_poc_sqs_queue.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${module.irsa.role_arn}"
          }
        }
      }
    ]
  }
  EOF
}