locals {
  sa_rules = [
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

module "serviceaccount_formbuilder-av-test-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-av-test-dev"
  role_name           = "formbuilder-av-test-dev"
  rolebinding_name    = "formbuilder-av-test-dev"
}

module "serviceaccount_formbuilder-pdf-generator-test-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-pdf-generator-test-dev"
  role_name           = "formbuilder-pdf-generator-test-dev"
  rolebinding_name    = "formbuilder-pdf-generator-test-dev"
}

module "serviceaccount_formbuilder-submitter-workers-test-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-submitter-workers-test-dev"
  role_name           = "formbuilder-submitter-workers-test-dev"
  rolebinding_name    = "formbuilder-submitter-workers-test-dev"
}

module "serviceaccount_formbuilder-user-datastore-test-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-user-datastore-test-dev"
  role_name           = "formbuilder-user-datastore-test-dev"
  rolebinding_name    = "formbuilder-user-datastore-test-dev"
}

module "serviceaccount_formbuilder-user-filestore-test-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-user-filestore-test-dev"
  role_name           = "formbuilder-user-filestore-test-dev"
  rolebinding_name    = "formbuilder-user-filestore-test-dev"
}
