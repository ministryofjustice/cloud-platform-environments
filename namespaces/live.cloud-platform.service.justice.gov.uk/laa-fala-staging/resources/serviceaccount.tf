module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "17-10-2023"

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources  = ["pods/exec"]
      verbs      = ["create"]
    },
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "pods",
        "configmaps",
        "persistentvolumeclaims",
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "update",
        "delete",
        "list",
        "watch"
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "statefulsets",
        "replicasets"
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list"
      ]
    },
  ]
  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["my-repo"]
  github_repositories                  = [var.repo_name]
}
