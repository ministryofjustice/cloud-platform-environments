data "aws_iam_policy_document" "ppud_document_storage" {
  statement {
    sid    = "DocumentBucketMetadata"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [module.documents_bucket.bucket_arn]
  }

  statement {
    sid    = "DocumentObjectReadWrite"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${module.documents_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "ppud_document_storage" {
  name   = "${var.namespace}-document-storage"
  path   = "/cloud-platform/ppud/"
  policy = data.aws_iam_policy_document.ppud_document_storage.json

  tags = {
    business-unit = var.business_unit
    application   = var.application
    is-production = var.is_production
    owner         = var.team_name
    namespace     = var.namespace
  }
}

module "ppud_backend_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "ppud-backend"
  namespace            = var.namespace
  role_policy_arns = {
    document_storage = aws_iam_policy.ppud_document_storage.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
