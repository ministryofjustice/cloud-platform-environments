module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = "ap-judicial-reviews-prod"
  role_policy_arns = [aws_iam_policy.ap-judicial-reviews-prod.arn]
}

data "aws_iam_policy_document" "ap-judicial-reviews-prod" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::alpha-app-judicial-reviews-app",
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
      "arn:aws:s3:::alpha-app-judicial-reviews-app/*",
    ]
  }
}

resource "aws_iam_policy" "ap-judicial-reviews-prod" {
  name   = "ap-judicial-reviews-prod"
  policy = data.aws_iam_policy_document.ap-judicial-reviews-prod.json

  tags = {
    business-unit          = "Cloud Platform"
    application            = "Judicial reviews app"
    is-production          = "true"
    environment-name       = "Production"
    owner                  = "cloud-platform"
    infrastructure-support = "platforms@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "ap-judicial-reviews-prod"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}
