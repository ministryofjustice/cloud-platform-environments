module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.bold-rr-ops-test_ap-access.arn]
}

data "aws_iam_policy_document" "bold-rr-ops-test_ap-access" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::alpha-app-bold-rr-ops-pilot",
    ]
  }
}

resource "aws_iam_policy" "bold-rr-ops-test_ap-access" {
  name   = "bold-rr-ops-test_ap-access"
  policy = data.aws_iam_policy_document.bold-rr-ops-test_ap-access.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role = module.irsa.aws_iam_role_name
    serviceaccount = module.irsa.service_account_name.name
  }
}
