module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.5"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_rules = var.serviceaccount_rules

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-test-viewer"]
  serviceaccount_name = "cd-serviceaccount"
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
        "replicaset",
        "ingress",
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
