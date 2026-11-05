data "aws_iam_policy_document" "ppud_documents" {
  statement {
    sid       = "ListDocumentBucket"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [module.documents_bucket.bucket_arn]
  }

  statement {
    sid = "ReadAndWriteDocumentsWithoutDeletion"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${module.documents_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "ppud_documents" {
  name        = "${var.namespace}-documents"
  description = "PPUD backend access to its document bucket without object deletion"
  policy      = data.aws_iam_policy_document.ppud_documents.json
}

data "aws_iam_policy_document" "ppud_legacy_export_read" {
  statement {
    sid       = "ListLegacyExportBucket"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [module.legacy_export_bucket.bucket_arn]
  }

  statement {
    sid       = "ReadLegacyExports"
    actions   = ["s3:GetObject"]
    resources = ["${module.legacy_export_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "ppud_legacy_export_read" {
  name        = "${var.namespace}-legacy-export-read"
  description = "Read-only legacy export access for the PPUD dev loader"
  policy      = data.aws_iam_policy_document.ppud_legacy_export_read.json
}

module "ppud_backend_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "ppud-backend"
  namespace            = var.namespace
  role_policy_arns = {
    documents = aws_iam_policy.ppud_documents.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ppud_legacy_loader_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "ppud-legacy-loader"
  namespace            = var.namespace
  role_policy_arns = {
    legacy_exports = aws_iam_policy.ppud_legacy_export_read.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
