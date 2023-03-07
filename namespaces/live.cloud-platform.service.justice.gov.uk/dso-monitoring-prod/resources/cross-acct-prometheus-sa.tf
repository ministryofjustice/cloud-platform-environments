module "irsa_prometheus" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.dso-monitoring-prometheus.arn]
  service_account  = var.prometheus_sa
}

data "aws_iam_policy_document" "dso-monitoring-prometheus" {
  # AssumeRole permissions for Prometheus EC2 discovery in
  # nomis-production mod-platform acct.
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.mp_account}:role/PrometheusEC2DiscoveryRole",
    ]
  }
}
resource "aws_iam_policy" "dso-monitoring-prometheus" {
  name   = "${var.namespace}-prometheus-policy"
  policy = data.aws_iam_policy_document.dso-monitoring-prometheus.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa_prometheus" {
  metadata {
    name      = "irsa-output-prometheus"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa_prometheus.aws_iam_role_name
    serviceaccount = module.irsa_prometheus.service_account_name.name
  }
}
