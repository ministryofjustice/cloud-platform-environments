module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "prisoner-content-hub"
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3     = module.drupal_content_storage_2.irsa_policy_arn
    s3prod = aws_iam_policy.s3_add_access_to_prod.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "s3_add_access_to_prod" {
  version = "2012-10-17"
  statement {
    sid    = "AllowBucketActions"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-ee432bcfffe38a157f08669a6d4b7740",
      "arn:aws:s3:::cloud-platform-ee432bcfffe38a157f08669a6d4b7740/*"
    ]
  }
}

resource "aws_iam_policy" "s3_add_access_to_prod" {
  policy = data.aws_iam_policy_document.s3_add_access_to_prod.json
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "content-hub-irsa"
    namespace = var.namespace
  }

  data = {
    role = module.irsa.role_arn
  }
}
