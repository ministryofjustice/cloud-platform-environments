module "hmpps_pin_phone_monitor_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "pin-phone-recording-expiry"
      prefix  = "recordings/"
      expiration = [
        {
          days = 10
        },
      ]
    },
  ]

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:ListBucket"
    ],
    "Resource": "$${bucket_arn}"
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:CopyObject",
      "s3:PutObjectTagging",
      "s3:DeleteObject"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF

}

module "hmpps_pin_phone_monitor_s3_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "hmpps_pin_phone_monitor_s3_event_queue_qa"
  encrypt_sqs_kms           = "false"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "hmpps_pin_phone_monitor_s3_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "hmpps_pin_phone_monitor_s3_event_dlq_qa"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_pin_phone_monitor_s3_event_queue_policy" {
  queue_url = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
         "Principal": {
            "Service": "s3.amazonaws.com"
         },
        "Action": "sqs:SendMessage",
        "Resource": "${module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn}",
        "Condition": {
          "ArnEquals": { "aws:SourceArn": "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}" }
        }
      }
    ]
  }
    EOF
}

resource "aws_s3_bucket_notification" "hmpps_pin_phone_monitor_s3_notification" {
  bucket = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_name

  queue {
    id        = "metadata-upload-event"
    queue_arn = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
    filter_prefix = "metadata/"
    filter_suffix = ".json"
  }

  queue {
    id        = "recording-deletion-event"
    queue_arn = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    events = [
    "s3:ObjectRemoved:Delete"]
    filter_prefix = "recordings/"
    filter_suffix = ".flac"
  }
}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_s3_event_queue" {
  metadata {
    name      = "hmpps-pin-phone-monitor-sqs-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_pin_phone_monitor_s3_event_queue.access_key_id
    secret_access_key = module.hmpps_pin_phone_monitor_s3_event_queue.secret_access_key
    sqs_url           = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_id
    sqs_arn           = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    sqs_name          = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_document_s3_bucket" {
  metadata {
    name      = "hmpps-pin-phone-monitor-document-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_pin_phone_monitor_document_s3_bucket.access_key_id
    secret_access_key = module.hmpps_pin_phone_monitor_document_s3_bucket.secret_access_key
    bucket_arn        = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn
    bucket_name       = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_s3_event_dead_letter_queue" {
  metadata {
    name      = "hmpps-pin-phone-monitor-sqs-dl-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.secret_access_key
    sqs_url           = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_id
    sqs_arn           = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_arn
    sqs_name          = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_name
  }
}

