module "serviceaccount_circleci" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  role_name = "circleci-legal-framework-uat-sa-migrated"
  rolebinding_name = "circleci-legal-framework-uat-sa-migrated"

  serviceaccount_token_rotated_date = "13-02-2024"
  serviceaccount_name = "circleci-migrated"
  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "pods",
        "persistentvolumeclaims",
        "serviceaccounts"
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "update",
        "delete",
        "list"
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
        "policy"
      ]
      resources = [
        "deployments",
        "ingresses",
        "statefulsets",
        "networkpolicies",
        "poddisruptionbudgets",
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
}

