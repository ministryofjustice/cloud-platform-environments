/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  lifecycle_rule = [
    {
      id      = "Retire Processed files after 7 days"
      enabled = true
      prefix  = "processed/"

      expiration = [
        {
          days = 7
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

    },
    {
      id      = "Retire Errored files after 7 days"
      enabled = true
      prefix  = "errored/"

      expiration = [
        {
          days = 7
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

    },
    {
      id      = "Retire Commitals after 7 days"
      enabled = true
      prefix  = "maat-xhibit/committal/incoming/"

      expiration = [
        {
          days = 7
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

    }
  ]


}

# Build the policy JSON using the module outputs (no feedback loop)
data "aws_iam_policy_document" "ap_ingestion" {
  statement {
    sid    = "AllowAnalyticalPlatformIngestionService"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::471112983409:role/transfer"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
    ]

    resources = ["${module.s3_bucket.bucket_arn}/*"]
  }


  statement {
    sid     = "AllowListBucketForAPIngestion"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::471112983409:role/transfer"]
    }

    actions   = ["s3:ListBucket"]
    resources = [module.s3_bucket.bucket_arn]
  }
}

# Attach the policy to the bucket as its own resource
resource "aws_s3_bucket_policy" "ap_ingestion" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.ap_ingestion.json
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
