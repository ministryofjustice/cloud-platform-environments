module "testserviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_name = var.serviceaccount_name_e2e_tests

  github_actions_secret_kube_cert     = "KUBE_CERT_${var.namespace}"
  github_actions_secret_kube_token    = "KUBE_TOKEN_${var.namespace}"
  github_actions_secret_kube_cluster  = "KUBE_CLUSTER_${var.namespace}"
  github_actions_secret_kube_namespace = "KUBE_NAMESPACE_${var.namespace}"

  github_repositories = ["bulk-submission-and-fee-scheme-tests-"]

  github_environments = ["uat"]
}
