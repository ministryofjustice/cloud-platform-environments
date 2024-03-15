/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  acl                           = "public-read"
  enable_allow_block_pub_access = false
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

resource "aws_s3_bucket_policy" "allow_irsa_write" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.allow_irsa_write.json
}

data "aws_iam_policy_document" "allow_irsa_write" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [module.irsa.role_arn]
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
