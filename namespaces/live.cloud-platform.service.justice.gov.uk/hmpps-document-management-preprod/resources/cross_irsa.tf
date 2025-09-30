module "cross_irsa" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  business_unit          = var.business_unit
  application            = var.application
  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "${var.namespace}-cross-service"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  role_policy_arns       = { s3 = aws_iam_policy.s3_sync_policy.arn }
}

data "aws_iam_policy_document" "s3_sync_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      module.s3.bucket_arn,
      module.s3-images.bucket_arn,
      "arn:aws:s3:::cloud-platform-86ce211134a73df3c03f1a87c1dbf0a7",
      "arn:aws:s3:::cloud-platform-f548ea4a5da62a1d1dff02ad6e1e2d42"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-86ce211134a73df3c03f1a87c1dbf0a7",
      "arn:aws:s3:::cloud-platform-f548ea4a5da62a1d1dff02ad6e1e2d42/*"
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
      "${module.s3-images.bucket_arn}/*"
      "${module.s3.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_sync_policy" {
  name   = "s3_sync_policy"
  policy = data.aws_iam_policy_document.s3_sync_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "cross_irsa" {
  metadata {
    name      = "cross-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.cross_irsa.role_name
    rolearn        = module.cross_irsa.role_arn
    serviceaccount = module.cross_irsa.service_account.name
  }
}

module "cross_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"
  namespace            = var.namespace
  service_account_name = module.cross_irsa.service_account.name
}