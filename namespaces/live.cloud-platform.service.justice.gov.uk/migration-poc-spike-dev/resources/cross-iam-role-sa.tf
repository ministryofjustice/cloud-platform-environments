module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.6"
  namespace        = "migration-poc-spike-dev"
  role_policy_arns = [aws_iam_policy.allow_s3_access.arn]
}

data "aws_iam_policy_document" "allow_s3_access" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::cp-app-migration-poc-dev",
    ]
  }

  statement {
    sid = "readwrite"
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
      "arn:aws:s3:::cp-app-migration-poc-dev/*",
    ]
  }
}

resource "aws_iam_policy" "allow_s3_access" {
  name   = "migration-poc-spike-dev-allow-s3-policy"
  policy = data.aws_iam_policy_document.allow_s3_access.json

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
    namespace = "migration-poc-spike-dev"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}
