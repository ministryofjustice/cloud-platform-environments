resource "helm_release" "cloud_platform_canary" {
  name       = "cloud-platform-canary-app"
  namespace  = "cloud-platform-canary-app-eks"
  repository = "https://stefanprodan.github.io/podinfo"
  chart      = "podinfo"
  version    = "6.1.7"

  values = [templatefile("${path.module}/values.yaml", {
    external_dns  = "cloud-platform-canary-app-podinfo-cloud-platform-canary-app-eks-green"
    host_name     = var.host_name
    ingress_class = "default"
  })]
}

resource "helm_release" "cloud_platform_modsec_canary" {
  name       = "cloud-platform-canary-app-modsec"
  namespace  = "cloud-platform-canary-app-eks"
  repository = "https://stefanprodan.github.io/podinfo"
  chart      = "podinfo"
  version    = "6.1.7"

  values = [templatefile("${path.module}/values.yaml", {
    external_dns  = "cloud-platform-canary-app-modsec-podinfo-cloud-platform-canary-app-eks-green"
    host_name     = "modsec-${var.host_name}"
    ingress_class = "modsec"
  })]
}
