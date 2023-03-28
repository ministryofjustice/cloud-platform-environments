module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = "data-platform-app-ap-shiny-cp-deployment-prod"
  role_policy_arns = [aws_iam_policy.data-platform-app-ap-shiny-cp-deployment-prod.arn]
}

data "aws_iam_policy_document" "data-platform-app-ap-shiny-cp-deployment-prod" {
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

resource "aws_iam_policy" "data-platform-app-ap-shiny-cp-deployment-prod" {
  name   = "data-platform-app-ap-shiny-cp-deployment-prod"
  policy = data.aws_iam_policy_document.data-platform-app-ap-shiny-cp-deployment-prod.json

  tags = {
    business-unit          = "Platforms"
    application            = "ap shiny cp deployment"
    is-production          = "true"
    environment-name       = "prod"
    owner                  = "analytical-platform"
    infrastructure-support = "analytics-platform-tech@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "data-platform-app-ap-shiny-cp-deployment-prod"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}