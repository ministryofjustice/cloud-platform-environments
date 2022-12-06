module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.5"
  namespace        = "ap-gold-scorecard-form-prod"
  role_policy_arns = [aws_iam_policy.ap-gold-scorecard-form-prod.arn]
}

data "aws_iam_policy_document" "ap-gold-scorecard-form-prod" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::alpha-app-scorecard-form",
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
      "arn:aws:s3:::alpha-app-scorecard-form/*",
    ]
  }
}

resource "aws_iam_policy" "ap-gold-scorecard-form-prod" {
  name   = "ap-gold-scorecard-form-prod"
  policy = data.aws_iam_policy_document.ap-gold-scorecard-form-prod.json

  tags = {
    business-unit          = "Cloud Platform"
    application            = "Test Migration"
    is-production          = "false"
    environment-name       = "Development"
    owner                  = "cloud-platform"
    infrastructure-support = "platforms@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "ap-gold-scorecard-form-prod"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}
