data "aws_iam_policy_document" "ppx_documents" {
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

resource "aws_iam_policy" "ppx_documents" {
  name        = "${var.namespace}-documents"
  description = "PPX backend access to its document bucket without object deletion"
  policy      = data.aws_iam_policy_document.ppx_documents.json
}

module "ppx_backend_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "ppx-backend"
  namespace            = var.namespace
  role_policy_arns = {
    documents = aws_iam_policy.ppx_documents.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

