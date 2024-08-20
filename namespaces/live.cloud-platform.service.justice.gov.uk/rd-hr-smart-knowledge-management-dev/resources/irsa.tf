locals {
  service_account_rules = [
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
        "update",
        "delete",
        "list",
        "watch",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "poddisruptionbudgets",
        "networkpolicies",
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
    {
      api_groups = [
        "monitoring.coreos.com",
      ]
      resources = [
        "prometheusrules",
        "servicemonitors",
      ]
      verbs = [
        "*",
      ]
    }
  ]
}

resource "kubernetes_service_account" "analytical_platform_access" {
  metadata {
    namespace = var.namespace
    name      = "${var.namespace}-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::593291632749:role/alpha_app_rd-hr-smart-knowledge-management"
    }
  }
}

resource "kubernetes_role" "application_service_account_role" {
  metadata {
    name      = "${var.namespace}-role"
    namespace = var.namespace
  }

  dynamic "rule" {
    for_each = toset(local.service_account_rules)
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_role_binding" "application_service_account_role_binding" {
  metadata {
    name      = "${var.namespace}-role-binding"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.application_service_account_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.analytical_platform_access.metadata[0].name
    namespace = var.namespace
  }
}
