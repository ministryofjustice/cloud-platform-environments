module "s3_data_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # Enable versioning to preserve old photos when updated
  versioning = true

  cors_rule =[
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://esupervision-test.hmpps.service.justice.gov.uk","https://manage-people-on-probation-test.hmpps.service.justice.gov.uk","https://probation-check-in-test.hmpps.service.justice.gov.uk","http://localhost:3000"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

# Bucket policy to allow Rekognition role to read S3 objects for facial comparison
resource "aws_s3_bucket_policy" "rekognition_access" {
  bucket = module.s3_data_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowRekognitionRoleAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.rekognition_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${module.s3_data_bucket.bucket_arn}/*"
      }
    ]
  })
}

# info about the bucket
resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "hmpps-esupervision-data-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_data_bucket.bucket_arn
    bucket_name = module.s3_data_bucket.bucket_name
  }
}
