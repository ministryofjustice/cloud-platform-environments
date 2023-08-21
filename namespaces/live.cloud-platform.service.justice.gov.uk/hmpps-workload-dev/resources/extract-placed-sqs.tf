module "hmpps_extract_placed_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_extract_placed_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_extract_placed_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "hmpps_extract_placed_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_extract_placed_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_extract_placed_queue_policy" {
  queue_url = module.hmpps_extract_placed_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_extract_placed_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
         "Principal": {
            "Service": "s3.amazonaws.com"
         },
        "Action": "sqs:SendMessage",
        "Resource": "${module.hmpps_extract_placed_queue.sqs_arn}",
        "Condition": {
          "ArnEquals": { "aws:SourceArn": "${module.hmpps-workload-dev-s3-extract-bucket.bucket_arn}" }
        }
      }
    ]
  }
    EOF
}

resource "kubernetes_secret" "hmpps_extract_placed_queue" {
  metadata {
    name      = "hmpps-extract-placed-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_extract_placed_queue.access_key_id
    secret_access_key = module.hmpps_extract_placed_queue.secret_access_key
    sqs_queue_url     = module.hmpps_extract_placed_queue.sqs_id
    sqs_queue_arn     = module.hmpps_extract_placed_queue.sqs_arn
    sqs_queue_name    = module.hmpps_extract_placed_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_extract_placed_dead_letter_queue" {
  metadata {
    name      = "hmpps-extract-placed-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_extract_placed_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_extract_placed_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_extract_placed_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_extract_placed_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_extract_placed_dead_letter_queue.sqs_name
  }
}
