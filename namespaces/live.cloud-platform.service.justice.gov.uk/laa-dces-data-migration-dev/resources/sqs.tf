module "dces_s3_object_created_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "dces_s3_object_created_queue"
  encrypt_sqs_kms           = "true"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.dces_s3_object_created_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "dces_s3_object_created_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "dces_s3_object_created_queue_dlq"
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

resource "aws_sqs_queue_policy" "dces_s3_object_created_queue_policy" {
  queue_url = module.dces_s3_object_created_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.dces_s3_object_created_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
         "Principal": {
            "Service": "s3.amazonaws.com"
         },
        "Action": "sqs:SendMessage",
        "Resource": "${module.dces_s3_object_created_queue.sqs_arn}",
        "Condition": {
          "ArnEquals": { "aws:SourceArn": "${module.dces_s3_bucket.bucket_arn}" }
        }
      }
    ]
  }
    EOF
    depends_on = [ module.dces_s3_bucket ]
}

resource "kubernetes_secret" "dces_s3_object_created_queue" {
  metadata {
    name      = "dces-s3-object-created-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.dces_s3_object_created_queue.sqs_id
    sqs_queue_arn  = module.dces_s3_object_created_queue.sqs_arn
    sqs_queue_name = module.dces_s3_object_created_queue.sqs_name
  }
}

resource "kubernetes_secret" "dces_s3_object_created_dead_letter_queue" {
  metadata {
    name      = "dces-s3-object-created-queue-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.dces_s3_object_created_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.dces_s3_object_created_dead_letter_queue.sqs_arn
    sqs_queue_name = module.dces_s3_object_created_dead_letter_queue.sqs_name
  }
}
