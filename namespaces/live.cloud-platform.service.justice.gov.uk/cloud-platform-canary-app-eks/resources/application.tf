resource "helm_release" "cloud_platform_canary" {
  name       = "cloud-platform-canary-application"
  namespace  = "cloud-platform-canary-app-eks"
  repository = "https://stefanprodan.github.io/podinfo"
  chart      = "podinfo"
  version    = "6.1.5"

  values = [
    file("values.yaml")
  ]
}
