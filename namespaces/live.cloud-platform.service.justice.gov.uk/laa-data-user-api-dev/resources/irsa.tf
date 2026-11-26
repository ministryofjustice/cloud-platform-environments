data "aws_iam_policy_document" "s3_read_opa" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [module.s3_opa.bucket_arn]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_opa.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_read_opa" {
  name   = "${var.namespace}-s3-read"
  policy = data.aws_iam_policy_document.s3_read_opa.json
}

data "aws_iam_policy_document" "s3_write_opa" {
  statement {
    actions   = ["s3:ListBucketMultipartUploads"]
    resources = [module.s3_opa.bucket_arn]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${module.s3_opa.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_write_opa" {
  name   = "${var.namespace}-s3-write"
  policy = data.aws_iam_policy_document.s3_write_opa.json
}

module "irsa_laa_data_user_api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "irsa-laa-data-user-api-${var.environment}"
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  role_policy_arns = {
    s3_read = aws_iam_policy.s3_read_opa.arn
  }
}

module "irsa_s3_writer_opa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "irsa-laa-data-user-api-s3-writer"
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  role_policy_arns = {
    s3_read  = aws_iam_policy.s3_read_opa.arn
    s3_write = aws_iam_policy.s3_write_opa.arn
  }
}
