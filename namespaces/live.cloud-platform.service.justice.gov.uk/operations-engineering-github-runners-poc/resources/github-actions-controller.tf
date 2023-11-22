resource "helm_release" "actions_scale_set_controller" {
  name       = "actions-runner-controller"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  namespace  = "operations-engineering-github-runners-poc"

  set {
    name  = "image.tag"
    value = "0.7.0"
  }
}

resource "helm_release" "operations_engineering_runners" {
  name       = "operations-engineering-private-runners"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  namespace  = "operations-engineering-github-runners-poc"

  set {
    name  = "githubConfigUrl"
    value = "https://github.com/ministryofjustice"
  }

  set {
    name  = "githubConfigSecret"
    value = "poc-classic-token"
  }

  set {
    name  = "template.spec.containers[0].name"
    value = "runner"
  }

  set {
    name  = "template.spec.containers[0].image"
    value = "json0/actions-runner:latest"
  }
}
