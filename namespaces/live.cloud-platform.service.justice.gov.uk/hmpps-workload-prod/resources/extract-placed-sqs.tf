module "hmpps_extract_placed_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_extract_placed_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_extract_placed_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "hmpps_extract_placed_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_extract_placed_dlq"
  encrypt_sqs_kms = "true"

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
          "ArnEquals": { "aws:SourceArn": "${module.hmpps-workload-prod-s3-extract-bucket.bucket_arn}" }
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
    sqs_queue_url  = module.hmpps_extract_placed_queue.sqs_id
    sqs_queue_arn  = module.hmpps_extract_placed_queue.sqs_arn
    sqs_queue_name = module.hmpps_extract_placed_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_extract_placed_dead_letter_queue" {
  metadata {
    name      = "hmpps-extract-placed-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_extract_placed_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_extract_placed_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_extract_placed_dead_letter_queue.sqs_name
  }
}
