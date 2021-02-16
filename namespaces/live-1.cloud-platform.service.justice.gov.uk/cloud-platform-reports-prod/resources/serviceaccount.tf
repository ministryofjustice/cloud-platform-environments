module "serviceaccount" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.4"
  namespace           = var.namespace
  github_repositories = ["cloud-platform-how-out-of-date-are-we"]
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
