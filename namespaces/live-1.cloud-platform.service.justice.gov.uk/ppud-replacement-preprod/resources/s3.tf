##
## Manage Recalls Document Storage
##

# Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
module "manage_recalls_s3_bucket_preprod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"

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

# This policy restricts access to the bucket to applications running within the VPC.
resource "aws_s3_bucket_policy" "manage_recalls_s3_bucket_policy_preprod" {
  bucket = module.manage_recalls_s3_bucket_preprod.bucket_name

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
          "s3:DeleteObject*",
        ]
        Resource = [
          module.manage_recalls_s3_bucket_preprod.bucket_arn,
          "${module.manage_recalls_s3_bucket_preprod.bucket_arn}/*",
        ]
        Condition = {
          "NotIpAddress" = {
            # Live-1 IP addresses
            "aws:SourceIp" = [
              "35.178.209.113", "3.8.51.207", "35.177.252.54"
            ]
          }
        }
      },
    ]
  })
}

resource "kubernetes_secret" "manage_recalls_s3_bucket_preprod" {
  metadata {
    name      = "manage-recalls-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.manage_recalls_s3_bucket_preprod.access_key_id
    secret_access_key = module.manage_recalls_s3_bucket_preprod.secret_access_key
    bucket_arn        = module.manage_recalls_s3_bucket_preprod.bucket_arn
    bucket_name       = module.manage_recalls_s3_bucket_preprod.bucket_name
  }
}

##
## Lumen Data Transfer
##

module "lumen_transfer_s3_bucket_preprod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"

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
    name      = "lumen-transfer-s3-bucket"
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
