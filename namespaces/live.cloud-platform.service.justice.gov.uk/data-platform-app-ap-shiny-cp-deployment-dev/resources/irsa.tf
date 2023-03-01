module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.6"
  namespace        = "data-platform-app-ap-shiny-cp-deployment-dev"
  role_policy_arns = [aws_iam_policy.data-platform-app-ap-shiny-cp-deployment-dev.arn]
}

data "aws_iam_policy_document" "data-platform-app-ap-shiny-cp-deployment-dev" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [

      "arn:aws:s3:::dev-analytics-platform-rshiny-notebook",

    ]
  }

  statement {
    sid = "readwritebucket"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:RestoreObject",
    ]
    resources = [

      "arn:aws:s3:::dev-analytics-platform-rshiny-notebook/*",

    ]
  }
}

resource "aws_iam_policy" "data-platform-app-ap-shiny-cp-deployment-dev" {
  name   = "data-platform-app-ap-shiny-cp-deployment-dev"
  policy = data.aws_iam_policy_document.data-platform-app-ap-shiny-cp-deployment-dev.json

  tags = {
    business-unit          = "Platforms"
    application            = "ap shiny cp deployment"
    is-production          = "false"
    environment-name       = "dev"
    owner                  = "analytical-platform"
    infrastructure-support = "analytics-platform-tech@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "data-platform-app-ap-shiny-cp-deployment-dev"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}