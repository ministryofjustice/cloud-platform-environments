module "irsa-grafana" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.4"
  namespace        = var.namespace
  role_policy_arns = [aws_iam_policy.dso-monitoring-grafana.arn]
  service_account  = var.grafana_sa
}

data "aws_iam_policy_document" "dso-monitoring-grafana" {
  # AssumeRole permissions for CloudWatch provider in
  # nomis-production mod-platform acct.
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.mp_account}:role/CloudwatchDatasourceRole",
    ]
  }
}
resource "aws_iam_policy" "dso-monitoring-grafana" {
  name   = "${var.namespace}-grafana-policy"
  policy = data.aws_iam_policy_document.dso-monitoring-grafana.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa-grafana" {
  metadata {
    name      = "irsa-output-grafana"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-grafana.aws_iam_role_name
    serviceaccount = module.irsa-grafana.service_account_name.name
  }
}
