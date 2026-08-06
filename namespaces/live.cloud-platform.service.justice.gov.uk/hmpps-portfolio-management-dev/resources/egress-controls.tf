module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.9"

  enable_envoy_setup     = true
  enable_egress_controls = true

  namespace = var.namespace
  vpc_name  = var.vpc_name

  envoy_extra_allowed_hosts_exact = [
    "justiceuk.sharepoint.com",
    "circleci.com",
    "monitoring-alerts-service.cloud-platform-monitoring-alerts",
    "login.microsoftonline.com",
    "graph.microsoft.com",
    "slack.com",
    "github.com",
    "api.applicationinsights.io", 
    "ghcr.io",
    "api.snyk.io",
    "quay.io"
  ]

  envoy_extra_allowed_hosts_suffixes = [
    ".githubusercontent.com",
    ".cache.amazonaws.com",
    ".veracode.com",
    ".github.com",
    ".github.io",
    ".slack.com",
    ".service.gov.uk"
  ]
}

resource "kubernetes_manifest" "allow_alertmanager_http_egress" {
  manifest = {
    apiVersion = "projectcalico.org/v3"
    kind       = "NetworkPolicy"
    metadata = {
      name      = "hmpps-allow-alertmanager-http-egress"
      namespace = var.namespace
    }
    spec = {
      order    = 34.5
      selector = "all()"
      egress = [
        {
          action   = "Allow"
          protocol = "TCP"
          destination = {
            namespaceSelector = "kubernetes.io/metadata.name == \"cloud-platform-monitoring-alerts\""
            ports             = [8080]
          }
        }
      ]
      types = ["Egress"]
    }
  }
}
