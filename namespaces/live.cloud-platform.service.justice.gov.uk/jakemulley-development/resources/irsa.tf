module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=main"

  eks_cluster_name = var.eks_cluster_name
  namespace        = "jakemulley-development"
  role_policy_arns = [aws_iam_policy.policy.arn]
}

data "aws_iam_policy_document" "document" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "jm-dev-irsa-test"
  policy      = data.aws_iam_policy_document.document.json
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "jakemulley-development"
  }

  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}
