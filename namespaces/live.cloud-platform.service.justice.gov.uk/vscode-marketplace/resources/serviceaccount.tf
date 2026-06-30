# Creates a Kubernetes service account with deploy permissions for this namespace
# and automatically populates the following GitHub Actions secrets:
#   - KUBE_CERT
#   - KUBE_TOKEN
#   - KUBE_CLUSTER
#   - KUBE_NAMESPACE

module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Populate GitHub Actions secrets in this repository automatically
  github_repositories = [var.github_repository]

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources  = ["pods", "pods/log", "configmaps", "services", "persistentvolumeclaims"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["apps"]
      resources  = ["deployments"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["batch"]
      resources  = ["jobs", "cronjobs"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["networking.k8s.io"]
      resources  = ["ingresses"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
  ]
}
