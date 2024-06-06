locals {
  # Tags
  default_tags = {
    business_unit    = var.business_unit
    application      = var.application
    is_production    = var.is_production
    environment_name = var.environment-name
    owner            = var.team_name
    namespace        = var.namespace
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_kendra_index" "main" {
  name        = "kendra-${var.application}-${var.environment-name}"
  description = "Kendra-${var.application}-${var.environment-name}"
  edition     = "DEVELOPER_EDITION"
  role_arn    = aws_iam_role.kendra_role.arn

  tags = local.default_tags
}

resource "aws_kendra_data_source" "s3" {
  index_id = aws_kendra_index.main.id
  name     = "ims_attachments_storage_bucket"
  type     = "S3"
  role_arn = aws_iam_role.kendra_role.arn
  schedule = "cron(45 14 * * ? *)"

  configuration {
    s3_configuration {
      bucket_name = module.ims_attachments_storage_bucket.bucket_name
    }
  }
}

################## Kendra Role and Polciy #########################

resource "aws_iam_role" "kendra_role" {
  name = "Kendra-Role-${var.application}-${var.environment-name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kendra.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "kendra_policy" {
  name        = "Kendra-Policy-${var.application}-${var.environment-name}"
  description = "Policy for AWS Kendra for ${var.application}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          module.ims_attachments_storage_bucket.bucket_arn,
          "${module.ims_attachments_storage_bucket.bucket_arn}/*"
        ]
      },
      {
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kendra_policy_attachment" {
  role       = aws_iam_role.kendra_role.name
  policy_arn = aws_iam_policy.kendra_policy.arn
}

################## IRSA Role and Polciy #########################

data "aws_iam_policy_document" "kendra_irsa" {
  version = "2012-10-17"
  statement {
    sid       = "AllowKendraActionsFor${random_id.id.hex}" # this is set to include the hex, so you can merge policies
    effect    = "Allow"
    actions   = ["kendra:Query"]
    resources = [aws_kendra_index.main.arn]
  }
}

resource "aws_iam_policy" "kendra_irsa" {
  name   = "cloud-platform-kendra-${random_id.id.hex}"
  path   = "/cloud-platform/kendra/"
  policy = data.aws_iam_policy_document.kendra_irsa.json
  tags   = local.default_tags
}

resource "kubernetes_secret" "kendra" {
  metadata {
    name      = "kendra-output"
    namespace = var.namespace
  }
  data = {
    kendra_index_arn  = aws_kendra_index.main.arn 
    kendra_index_name = aws_kendra_index.main.name
  }
}