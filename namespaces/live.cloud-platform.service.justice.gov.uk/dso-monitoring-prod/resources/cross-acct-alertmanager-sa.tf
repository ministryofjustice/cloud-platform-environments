module "irsa_alertmanager" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=rm-sa"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.dso-monitoring-alertmanager.arn]
  service_account  = var.alertmanager_sa
}

data "aws_iam_policy_document" "dso-monitoring-alertmanager" {
  # AssumeRole permissions for Alertmanager SNS Topic role in
  # nomis-production mod-platform acct.
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.mp_account}:role/AlertmanagerSNSTopicRole",
    ]
  }
}
resource "aws_iam_policy" "dso-monitoring-alertmanager" {
  name   = "${var.namespace}-alertmanager-policy"
  policy = data.aws_iam_policy_document.dso-monitoring-alertmanager.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa_alertmanager" {
  metadata {
    name      = "irsa-output-alertmanager"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa_alertmanager.aws_iam_role_name
    serviceaccount = module.irsa_alertmanager.service_account_name.name
  }
}
