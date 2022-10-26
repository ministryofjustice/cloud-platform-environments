module "hmpps-workload-dev-s3-extract-bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7.1"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  versioning = true

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire extracts after 30 days"
      prefix  = "extract/"
      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]
      expiration = [
        {
          days = 30
        },
      ]
    }
  ]


  bucket_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3PutPolicy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::050243167760:root"
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "$${bucket_arn}/*",
                "$${bucket_arn}"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
             "Sid": "S3ListPolicy",
             "Effect": "Allow",
             "Principal": {
                 "AWS": "arn:aws:iam::050243167760:root"
             },
             "Action": [
                  "s3:List*",
                  "s3:DeleteObject*",
                  "s3:GetObject*",
                  "s3:GetBucketLocation"
             ],
             "Resource": [
                  "$${bucket_arn}/*",
                  "$${bucket_arn}"
             ]
        }
    ]
}
EOF


}

module "hmpps_workload_s3_extract_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_workload_s3_extract_event_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_workload_s3_extract_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "hmpps_workload_s3_extract_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_workload_s3_extract_event_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "hmpps_workload_s3_extract_event_queue_policy" {

  statement {
    sid     = "TopicToQueue"
    effect  = "Allow"
    actions = ["SQS:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.extract-placed-topic.topic_arn]
    }
    resources = [module.hmpps_workload_s3_extract_event_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "hmpps_workload_s3_extract_event_queue_policy" {
  queue_url = module.hmpps_workload_s3_extract_event_queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps_workload_s3_extract_event_queue_policy.json
}

resource "aws_sns_topic_subscription" "hmpps_workload_s3_extract_event_queue_subscription" {
  provider  = aws.london
  topic_arn = module.extract-placed-topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps_workload_s3_extract_event_queue.sqs_arn
}

resource "aws_s3_bucket_notification" "hmpps_workload_s3_notification" {
  bucket = module.hmpps-workload-dev-s3-extract-bucket.bucket_name

  topic {
    id        = "wmt-extract-upload-event"
    topic_arn = module.extract-placed-topic.topic_arn
    events = [
    "s3:ObjectCreated:*"]
    filter_prefix = "extract/"
  }

}

resource "kubernetes_secret" "hmpps_workload_s3_extract_event_queue" {
  metadata {
    name      = "hmpps-workload-s3-extract-sqs-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_workload_s3_extract_event_queue.access_key_id
    secret_access_key = module.hmpps_workload_s3_extract_event_queue.secret_access_key
    sqs_url           = module.hmpps_workload_s3_extract_event_queue.sqs_id
    sqs_arn           = module.hmpps_workload_s3_extract_event_queue.sqs_arn
    sqs_name          = module.hmpps_workload_s3_extract_event_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_workload_s3_extract_event_dead_letter_queue" {
  metadata {
    name      = "hmpps-workload-s3-extract-sqs-dl-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_workload_s3_extract_event_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_workload_s3_extract_event_dead_letter_queue.secret_access_key
    sqs_url           = module.hmpps_workload_s3_extract_event_dead_letter_queue.sqs_id
    sqs_arn           = module.hmpps_workload_s3_extract_event_dead_letter_queue.sqs_arn
    sqs_name          = module.hmpps_workload_s3_extract_event_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps-workload-dev-s3-extract-bucket" {
  metadata {
    name      = "s3-extract-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps-workload-dev-s3-extract-bucket.access_key_id
    secret_access_key = module.hmpps-workload-dev-s3-extract-bucket.secret_access_key
    bucket_arn        = module.hmpps-workload-dev-s3-extract-bucket.bucket_arn
    bucket_name       = module.hmpps-workload-dev-s3-extract-bucket.bucket_name
  }
}
