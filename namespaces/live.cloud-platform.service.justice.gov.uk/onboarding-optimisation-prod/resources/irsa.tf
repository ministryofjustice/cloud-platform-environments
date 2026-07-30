module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "${var.application}-${var.environment}-sa"

  role_policy_arns = {
    document_storage = aws_iam_policy.document_storage.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "document_storage" {
  provider = aws.london

  statement {
    sid    = "DocumentStorageObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${module.s3_bucket.bucket_arn}/documents/*"]
  }
}

resource "aws_iam_policy" "document_storage" {
  provider = aws.london

  name_prefix = "${var.application}-${var.environment}-documents-"
  description = "Least-privilege document storage access for ${var.namespace}"
  policy      = data.aws_iam_policy_document.document_storage.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
    owner                  = var.team_name
  }
}

resource "github_actions_environment_variable" "app_role_arn" {
  repository    = "onboarding-optimisation"
  environment   = "prod"
  variable_name = "APP_ROLE_ARN"
  value         = module.irsa.role_arn
}
