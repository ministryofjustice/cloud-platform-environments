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

module "serviceaccount_formbuilder-av-test-production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-av-test-production"
  role_name           = "formbuilder-av-test-production"
  rolebinding_name    = "formbuilder-av-test-production"
}

module "serviceaccount_formbuilder-pdf-generator-test-production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-pdf-generator-test-production"
  role_name           = "formbuilder-pdf-generator-test-production"
  rolebinding_name    = "formbuilder-pdf-generator-test-production"
}

module "serviceaccount_formbuilder-submitter-workers-test-production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-submitter-workers-test-production"
  role_name           = "formbuilder-submitter-workers-test-production"
  rolebinding_name    = "formbuilder-submitter-workers-test-production"
}

module "serviceaccount_formbuilder-user-datastore-test-production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-user-datastore-test-production"
  role_name           = "formbuilder-user-datastore-test-production"
  rolebinding_name    = "formbuilder-user-datastore-test-production"
}

module "serviceaccount_formbuilder-user-filestore-test-production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_rules = local.sa_rules

  serviceaccount_name = "formbuilder-user-filestore-test-production"
  role_name           = "formbuilder-user-filestore-test-production"
  rolebinding_name    = "formbuilder-user-filestore-test-production"
}
