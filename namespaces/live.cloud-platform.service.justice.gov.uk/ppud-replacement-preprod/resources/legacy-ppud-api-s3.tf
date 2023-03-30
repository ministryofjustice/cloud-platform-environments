##
## Lumen Data Transfer - Used for the DB snapshot transfer
##

module "lumen_transfer_s3_bucket_preprod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  infrastructure-support = var.infrastructure_support

  is-production    = var.is_production
  environment-name = var.environment
  namespace        = var.namespace

  providers = {
    aws = aws.london
  }

  versioning = false
}

resource "kubernetes_secret" "lumen_transfer_s3_bucket_preprod" {
  metadata {
    name      = "lumen-db-transfer-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.lumen_transfer_s3_bucket_preprod.access_key_id
    secret_access_key = module.lumen_transfer_s3_bucket_preprod.secret_access_key
    bucket_arn        = module.lumen_transfer_s3_bucket_preprod.bucket_arn
    bucket_name       = module.lumen_transfer_s3_bucket_preprod.bucket_name
  }
}

resource "aws_iam_instance_profile" "lumen_transfer_s3_iam_instance_profile" {
  name = "lumen-transfer-s3-iam-instance-profile-preprod"
  role = aws_iam_role.lumen_transfer_s3_iam_role.id
}

resource "aws_iam_role" "lumen_transfer_s3_iam_role" {
  name = "lumen-transfer-s3-iam-role-preprod"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lumen_transfer_s3_iam_role_policy" {
  name = "lumen-transfer-s3-iam-role-policy-preprod"
  role = aws_iam_role.lumen_transfer_s3_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = module.lumen_transfer_s3_bucket_preprod.bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = "${module.lumen_transfer_s3_bucket_preprod.bucket_arn}/*"
      }
    ]
  })
}

##
## Lumen Document Store - This is where Lumen/PPUD will push documents for us
##

module "lumen_document_store" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  infrastructure-support = var.infrastructure_support

  is-production    = var.is_production
  environment-name = var.environment
  namespace        = var.namespace

  providers = {
    aws = aws.london
  }

  versioning = false
}

resource "kubernetes_secret" "lumen_document_store" {
  metadata {
    name      = "lumen-document-store-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.lumen_document_store.access_key_id
    secret_access_key = module.lumen_document_store.secret_access_key
    bucket_arn        = module.lumen_document_store.bucket_arn
    bucket_name       = module.lumen_document_store.bucket_name
  }
}

# Extra user for Lumen to access the bucket
resource "aws_iam_user" "lumen_document_store_user" {
  name = "lumen_legacy_ppud_doc_store_s3_access_${var.environment}"
  path = "/system/lumen_legacy_ppud_doc_store_s3_access/"
}

resource "aws_iam_access_key" "lumen_document_store_user" {
  user = aws_iam_user.lumen_document_store_user.name
}

resource "aws_iam_user_policy" "lumen_document_store_user" {
  name = "lumen_legacy_ppud_doc_store_s3_access_${var.environment}"
  user = aws_iam_user.lumen_document_store_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = module.lumen_document_store.bucket_arn
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect   = "Allow"
        Resource = "${module.lumen_document_store.bucket_arn}/*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectTagging",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:PutObject",
          "s3:PutObjectTagging"
        ]
      }
    ]
  })
}

resource "kubernetes_secret" "lumen_document_store_user" {
  metadata {
    name      = "lumen-document-store-s3-bucket-lumen-user"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.lumen_document_store_user.id
    secret_access_key = aws_iam_access_key.lumen_document_store_user.secret
    bucket_arn        = module.lumen_document_store.bucket_arn
    bucket_name       = module.lumen_document_store.bucket_name
  }
}
