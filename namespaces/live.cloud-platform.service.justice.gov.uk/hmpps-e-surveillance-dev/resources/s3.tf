module "s3" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  bucket_name = var.s3_bucket_name
  versioning  = true

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_s3_bucket_notification" "file_upload_notification" {
  bucket = module.s3.bucket_name

  topic {
    topic_arn = module.sns_topic_file_upload.topic_arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [module.sns_topic_file_upload]
}

resource "aws_sns_topic_policy" "file_upload" {
  arn = module.sns_topic_file_upload.topic_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3Publish"
        Effect    = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = module.sns_topic_file_upload.topic_arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = module.s3.bucket_arn
          }
        }
      }
    ]
  })
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "people-and-events-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3.bucket_arn
    bucket_name = module.s3.bucket_name
  }
}
