module "cross_irsa_dev_test" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  business_unit          = var.business_unit
  application            = var.application
  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "${var.namespace}-cross-srv-tst"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  role_policy_arns       = { s3 = aws_iam_policy.s3_sync_policy_dev_test.arn }
}

data "aws_iam_policy_document" "s3_sync_policy_dev_tst" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      module.s3-images.bucket_arn,
      module.s3.bucket_arn,
      module.s3-dev-test.bucket_arn
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging"
    ]
    resources = [
      "${module.s3-dev-test.bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${module.s3.bucket_arn}/*",
      "${module.s3-images.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_sync_policy_dev_test" {
  name   = "s3_sync_policy_dev_test"
  policy = data.aws_iam_policy_document.s3_sync_policy_dev_tst.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "cross_irsa_dev_test" {
  metadata {
    name      = "cross-irsa-dev-test-output"
    namespace = var.namespace
  }
  data = {
    role           = module.cross_irsa_dev_test.role_name
    rolearn        = module.cross_irsa_dev_test.role_arn
    serviceaccount = module.cross_irsa_dev_test.service_account.name
  }
}

data "aws_iam_policy_document" "allow_dev_irsa_read" {
  statement {
    sid    = "AllowSourceBucketAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::754256621582:role/cloud-platform-irsa-b4e9e332a070ed0e-live"]
    }

    resources = [
      module.s3-dev-test.bucket_arn,
      "${module.s3-dev-test.bucket_arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_dev_irsa_read" {
  bucket = module.s3-dev-test.bucket_name
  policy = data.aws_iam_policy_document.allow_dev_irsa_read.json
}

module "tst_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"
  namespace            = var.namespace
  service_account_name = module.cross_irsa_dev_test.service_account.name
}
