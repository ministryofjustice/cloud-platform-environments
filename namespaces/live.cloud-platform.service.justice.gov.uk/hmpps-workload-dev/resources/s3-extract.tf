module "hmpps-workload-dev-s3-extract-bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

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


resource "aws_s3_bucket_notification" "hmpps_workload_s3_notification" {
  bucket = module.hmpps-workload-dev-s3-extract-bucket.bucket_name

  queue {
    id        = "wmt-extract-upload-event"
    queue_arn = module.hmpps_extract_placed_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
    filter_prefix = "extract/"
  }
}


resource "kubernetes_secret" "hmpps-workload-dev-s3-extract-bucket" {
  metadata {
    name      = "s3-extract-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps-workload-dev-s3-extract-bucket.bucket_arn
    bucket_name = module.hmpps-workload-dev-s3-extract-bucket.bucket_name
  }
}
