module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_name = "circleci-terraform-module-formbuilder-saas-live"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["fb-editor", "fb-metadata-api", "fb-av"]

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods"
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
        "monitoring.coreos.com",
        "networking.k8s.io",
        "batch"
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "statefulsets",
        "poddisruptionbudgets",
        "networkpolicies",
        "servicemonitors"
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch"
      ]
    },
    {
      api_groups = [
        "autoscaling"
      ]
      resources = [
        "hpa",
        "horizontalpodautoscalers"
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch"
      ]
    }
  ]
}
