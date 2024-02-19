module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_rules = var.serviceaccount_rules

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories                  = ["laa-claim-non-standard-magistrate-fee-backend"]
  github_environments                  = ["development"]
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster
}
variable "serviceaccount_rules" {
  description = "The capabilities of this serviceaccount"

  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))

  # These values are usually sufficient for a CI/CD pipeline
  default = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods",
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "delete",
        "list",
        "watch",
        "update",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "networking.k8s.io",
      ]
      resources = [
        "deployments",
        "ingresses",
        "replicasets"
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch",
      ]
    },
  ]
}
