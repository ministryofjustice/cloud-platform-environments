resource "helm_release" "actions_scale_set_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "gha-runner-scale-set-controller"
  namespace  = "operations-engineering-github-runners-poc"

  set {
    name  = "image.tag"
    value = "0.7.0"
  }
}
