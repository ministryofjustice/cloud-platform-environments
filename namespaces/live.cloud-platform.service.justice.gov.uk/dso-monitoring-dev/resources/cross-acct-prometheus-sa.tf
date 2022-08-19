module "irsa_prometheus" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.4"
  namespace        = var.namespace
  role_policy_arns = [aws_iam_policy.dso-monitoring-dev_prometheus-dev.arn]
  service_account  = var.prometheus_sa
}

data "aws_iam_policy_document" "dso-monitoring-dev_prometheus-dev" {
  # AssumeRole permissions for Prometheus EC2 discovery in
  # nomis-test mod-platform acct.
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.mp_account}:role/PrometheusEC2DiscoveryRole",
    ]
  }
}
resource "aws_iam_policy" "dso-monitoring-dev_prometheus-dev" {
  name   = "dso-monitoring-dev-prometheus-dev-policy"
  policy = data.aws_iam_policy_document.dso-monitoring-dev_prometheus-dev.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = "false"
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa_prometheus" {
  metadata {
    name      = "irsa-output-prometheus-dev"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa_prometheus.aws_iam_role_name
    serviceaccount = module.irsa_prometheus.service_account_name.name
  }
}
