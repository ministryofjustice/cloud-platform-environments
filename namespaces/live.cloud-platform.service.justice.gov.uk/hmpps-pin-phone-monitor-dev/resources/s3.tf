module "hmpps_pin_phone_monitor_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7"
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
      id      = "pin-phone-data-expiry"
      prefix  = "recordings/"
      expiration = [
        {
          days = 90
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

# This policy restricts object level access to the bucket to applications running within the VPC and known MoJ VPNs.
resource "aws_s3_bucket_policy" "hmpps_pin_phone_monitor_s3_ip_deny_policy" {
  bucket = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "SourceIP"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:GetObject*",
          "s3:DeleteObject*",
        ]
        Resource = [
          module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn,
          "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*",
        ]
        Condition = {
          "NotIpAddress" = {
            # Live-1 IP and MoJ VPN addresses
            "aws:SourceIp" = [
              "35.178.209.113",
              "3.8.51.207",
              "35.177.252.54",
              "81.134.202.29/32",
              "51.149.250.0/24",
              "51.149.251.0/24",
              "35.176.93.186/32"
            ]
          },
          "Bool" : { "aws:ViaAWSService" : "false" }
        }
      },
    ]
  })
}

module "hmpps_pin_phone_monitor_s3_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "hmpps_pin_phone_monitor_s3_event_queue_dev"
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "hmpps_pin_phone_monitor_s3_event_dlq_dev"
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
    id        = "transcript-creation-event-json"
    queue_arn = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
    filter_prefix = "transcripts/"
    filter_suffix = ".json"
  }

  queue {
    id        = "transcript-creation-event-txt"
    queue_arn = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
    filter_prefix = "transcripts/"
    filter_suffix = ".txt"
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

resource "kubernetes_secret" "pcms_s3_event_queue" {
  metadata {
    name      = "pcms-sqs-output"
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

resource "kubernetes_secret" "pcms_document_s3_bucket" {
  metadata {
    name      = "pcms-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_pin_phone_monitor_document_s3_bucket.access_key_id
    secret_access_key = module.hmpps_pin_phone_monitor_document_s3_bucket.secret_access_key
    bucket_arn        = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn
    bucket_name       = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "pcms_s3_event_dead_letter_queue" {
  metadata {
    name      = "pcms-sqs-dl-output"
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

