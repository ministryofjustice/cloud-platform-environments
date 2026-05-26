module "apex-migration-s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  # S3 configuration
  versioning = true

  # Tags
  business_unit          = var.business_unit
  application            = local.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
              "arn:aws:sts::754256621582:assumed-role/access-via-github/Tim97eng",
              "arn:aws:sts::754256621582:assumed-role/access-via-github/mark-butler-solirius"
          ]
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "$${bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = [
              "arn:aws:sts::754256621582:assumed-role/access-via-github/Tim97eng",
              "arn:aws:sts::754256621582:assumed-role/access-via-github/mark-butler-solirius"
          ]
        },
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "$${bucket_arn}"
        ]
      }
    ]
  })
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn           = module.apex-migration-s3.bucket_arn
    bucket_name          = module.apex-migration-s3.bucket_name
    s3_access_user_arn   = aws_iam_user.s3_user.arn
    s3_access_key_id     = aws_iam_access_key.s3_user.id
    s3_secret_access_key = aws_iam_access_key.s3_user.secret
  }
}
