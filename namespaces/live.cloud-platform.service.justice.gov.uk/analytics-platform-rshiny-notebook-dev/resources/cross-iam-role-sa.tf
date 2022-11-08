module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.5"
  namespace        = "analytics-platform-rshiny-notebook-dev"
  role_policy_arns = [aws_iam_policy.analytics-platform-rshiny-notebook-dev.arn]
}

data "aws_iam_policy_document" "analytics-platform-rshiny-notebook-dev" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
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

  statement {
    sid = "readsecrets"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-1:593291632749:secret:dev/apps/analytics-platform-rshiny-notebook/auth-xezVcI",
      "arn:aws:secretsmanager:eu-west-1:593291632749:secret:dev/apps/analytics-platform-rshiny-notebook/parameters-IzayX8",
    ]
  }

  statement {
    sid = "listsecrets"
    acrions = [
      "secretsmanager:ListSecrets",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "analytics-platform-rshiny-notebook-dev" {
  name   = "analytics-platform-rshiny-notebook-dev"
  policy = data.aws_iam_policy_document.analytics-platform-rshiny-notebook-dev.json

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
    namespace = "analytics-platform-rshiny-notebook-dev"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}
