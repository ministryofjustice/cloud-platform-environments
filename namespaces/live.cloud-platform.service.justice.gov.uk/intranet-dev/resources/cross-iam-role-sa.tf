module "cross_irsa" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  business_unit          = var.business_unit
  application            = var.application
  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "${var.namespace}-cross-service"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  role_policy_arns       = { s3 = aws_iam_policy.intranet_dev_s3_staging.arn }
}

data "aws_iam_policy_document" "intranet_dev_s3_staging" {
  # A list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::intranet2-staging-storage-h1d4c9820k0u"
    ]
  }
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::intranet2-staging-storage-h1d4c9820k0u/*"
    ]
  }
}

resource "aws_iam_policy" "intranet_dev_s3_staging" {
  name   = "intranet_dev_s3_staging"
  policy = data.aws_iam_policy_document.intranet_dev_s3_staging.json

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
    role = module.cross_irsa.aws_iam_role_name
    serviceaccount = module.cross_irsa.service_account_name.name
  }
}
