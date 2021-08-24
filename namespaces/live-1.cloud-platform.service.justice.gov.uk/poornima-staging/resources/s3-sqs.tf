module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  versioning = true

  providers = {
    aws = aws.london
  }

}

module "s3_bucket_sqs_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.3"

  environment-name          = var.environment_name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "s3_events_sqs_queue"
  encrypt_sqs_kms           = "false"
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.s3_bucket_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "s3_bucket_sqs_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.3"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "s3_events_dead_letter_queue"
  encrypt_sqs_kms        = "false"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "s3_bucket_queue_policy" {
  queue_url = module.s3_bucket_sqs_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.s3_bucket_sqs_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
         "Principal": {
            "Service": "s3.amazonaws.com"
         },
        "Action": "sqs:SendMessage",
        "Resource": "${module.s3_bucket_sqs_queue.sqs_arn}",
        "Condition": {
          "ArnEquals": { "aws:SourceArn": "${module.s3_bucket.bucket_arn}" }
        }
      }
    ]
  }
    EOF
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = module.s3_bucket.bucket_name

  queue {
    id        = "wmt-extract-upload-event"
    queue_arn = module.s3_bucket_sqs_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
  }

}

resource "kubernetes_secret" "sqs_queue" {
  metadata {
    name      = "sqs-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3_bucket_sqs_queue.access_key_id
    secret_access_key = module.s3_bucket_sqs_queue.secret_access_key
    sqs_url           = module.s3_bucket_sqs_queue.sqs_id
    sqs_arn           = module.s3_bucket_sqs_queue.sqs_arn
    sqs_name          = module.s3_bucket_sqs_queue.sqs_name
  }
}

resource "kubernetes_secret" "s3_bucket_dead_letter_queue" {
  metadata {
    name      = "sqs-dl-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3_bucket_dead_letter_queue.access_key_id
    secret_access_key = module.s3_bucket_dead_letter_queue.secret_access_key
    sqs_url           = module.s3_bucket_dead_letter_queue.sqs_id
    sqs_arn           = module.s3_bucket_dead_letter_queue.sqs_arn
    sqs_name          = module.s3_bucket_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "s3_bucket_for_sqs" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3_bucket.access_key_id
    secret_access_key = module.s3_bucket.secret_access_key
    bucket_arn        = module.s3_bucket.bucket_arn
    bucket_name       = module.s3_bucket.bucket_name
  }
}
