module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  bucket_name = "cloud-platform-vulnerability-reports"

lifecycle_rule = [
    {
      enabled = true
      id      = "remove old vulnerabilities after 180 days for live"
      prefix  = "live"

      expiration = [
        {
          days = 180
        },
      ]
    },
{
      enabled = true
      id      = "remove old vulnerabilities after 180 days for manager"
      prefix  = "manager"

      expiration = [
        {
          days = 180
        },
      ]
    }
  ]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

resource "aws_s3_bucket_policy" "allow_access" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.allow_access.json
}

data "aws_iam_policy_document" "allow_access" {
  statement {
    sid = "AllowAccessForManagerConcourse"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.manager_concourse.arn]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*",
    ]
  }

  statement {
    sid = "AllowAccessForReadOnly"
    principals {
      type        = "AWS"
      identifiers = [module.s3-irsa.role_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*",
    ]
  }
}

data "aws_iam_user" "manager_concourse" {
  user_name = "manager-concourse"
}
