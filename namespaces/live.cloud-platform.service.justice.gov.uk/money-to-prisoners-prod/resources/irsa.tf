# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
module "irsa-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.analytical-platform.arn]
  service_account  = "${var.namespace}-api"
  # NB: service account name must be unique within Cloud Platform (IAM role name is derived from it)
}

resource "aws_iam_policy" "analytical-platform" {
  name   = "${var.namespace}-analytical-platform"
  policy = data.aws_iam_policy_document.analytical-platform.json
  # NB: IAM policy name must be unique within Cloud Platform

  tags = {
    business-unit          = var.business_unit
    team_name              = var.team_name
    application            = var.application
    is-production          = var.is-production
    namespace              = var.namespace
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

data "aws_iam_policy_document" "analytical-platform" {
  # Allows direct put access to "landing" S3 bucket for Prison Network App in Analytical Platform AWS account (mojap)
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::mojap-land/hmpps/prisoner-money/*",
    ]
  }
}

resource "kubernetes_secret" "irsa-api" {
  metadata {
    name      = "irsa-api"
    namespace = var.namespace
  }

  data = {
    role            = module.irsa-api.aws_iam_role_name
    role_arn        = module.irsa-api.aws_iam_role_arn
    service_account = module.irsa-api.service_account_name.name
  }
}
