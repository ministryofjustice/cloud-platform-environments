module "hmpps_pin_phone_monitor_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
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
          days = 90
        },
      ],
      noncurrent_version_expiration = [
        {
          days = 1
        },
      ]
    },
    {
      enabled = true
      id      = "pin-phone-transcript-expiry"
      prefix  = "transcripts/"
      expiration = [
        {
          days = 90
        },
      ],
      noncurrent_version_expiration = [
        {
          days = 1
        },
      ]
    },
    {
      enabled = true
      id      = "pin-phone-translation-expiry"
      prefix  = "translations/"
      expiration = [
        {
          days = 90
        },
      ],
      noncurrent_version_expiration = [
        {
          days = 1
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
      "s3:GetObjectRetention",
      "s3:CopyObject",
      "s3:PutObject",
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
          "s3:PutObject*",
          "s3:List*",
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
              "35.176.93.186/32",
              "194.33.249.0/24",
              "194.73.47.216/29",
            ]
          },
          "Bool" = { "aws:ViaAWSService" : "false" },
          "StringNotEquals" = {
            "aws:PrincipalArn" = [
              aws_iam_role.translate_s3_data_role.arn,
              aws_iam_role.transcribe_s3_data_role.arn,
              aws_iam_user.bt_upload_user.arn
            ]
          }
        }
      },
    ]
  })
}

resource "aws_iam_role" "translate_s3_data_role" {
  name = "pcms-prod-translate-s3-data-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "translate.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "translate_s3_data_role_policy" {
  name = "pcms-prod-translate-s3-data-role-policy"
  role = aws_iam_role.translate_s3_data_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*",
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn,
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*",
      }
    ]
  })
}

resource "aws_iam_role" "transcribe_s3_data_role" {
  name = "pcms-prod-transcribe-s3-data-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "transcribe.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "transcribe_s3_data_role_policy" {
  name = "pcms-prod-transcribe-s3-data-role-policy"
  role = aws_iam_role.transcribe_s3_data_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*",
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn,
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*",
      }
    ]
  })
}

module "hmpps_pin_phone_monitor_s3_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "hmpps_pin_phone_monitor_s3_event_queue_prod"
  encrypt_sqs_kms           = "false"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

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

module "hmpps_pin_phone_monitor_s3_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hmpps_pin_phone_monitor_s3_event_dlq_prod"
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
    id        = "translation-creation-event-txt"
    queue_arn = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
    filter_prefix = "translations/"
    filter_suffix = ".txt"
  }
}

resource "kubernetes_secret" "pcms_s3_event_queue" {
  metadata {
    name      = "pcms-sqs-output"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_id
    sqs_arn  = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_arn
    sqs_name = module.hmpps_pin_phone_monitor_s3_event_queue.sqs_name
  }
}

resource "kubernetes_secret" "pcms_document_s3_bucket" {
  metadata {
    name      = "pcms-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn                  = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn
    bucket_name                 = module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_name
    translate_s3_data_role_arn  = aws_iam_role.translate_s3_data_role.arn
    transcribe_s3_data_role_arn = aws_iam_role.transcribe_s3_data_role.arn
  }
}

resource "kubernetes_secret" "pcms_s3_event_dead_letter_queue" {
  metadata {
    name      = "pcms-sqs-dl-output"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_id
    sqs_arn  = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_arn
    sqs_name = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.sqs_name
  }
}
