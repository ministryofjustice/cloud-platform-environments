resource "helm_release" "cloud_platform_canary" {
  name       = "cloud-platform-canary-application"
  namespace  = "cloud-platform-canary-app"
  repository = "https://stefanprodan.github.io/podinfo"
  chart      = "podinfo"
  version    = "5.1.2"

  values = [
    "${file("values.yaml")}"
  ]
}
