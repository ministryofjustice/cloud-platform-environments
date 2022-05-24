module "irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.3"
  namespace        = var.namespace
  role_policy_arns = [aws_iam_policy.dso-monitoring-dev_grafana-dev.arn]
  service_account  = "grafana-dev"
}

data "aws_iam_policy_document" "dso-monitoring-dev_grafana-dev" {
  # AssumeRole permissions for CloudWatch provider in
  # nomis-test mod-platform acct.
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::612659970365:role/CloudwatchDatasourceRole",
    ]
  }
}
resource "aws_iam_policy" "dso-monitoring-dev_grafana-dev" {
  name   = "dso-monitoring-dev-grafana-dev-policy"
  policy = data.aws_iam_policy_document.dso-monitoring-dev_grafana-dev.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = "false"
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output-grafana-dev"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.aws_iam_role_name
    serviceaccount = module.irsa.service_account_name.name
  }
}