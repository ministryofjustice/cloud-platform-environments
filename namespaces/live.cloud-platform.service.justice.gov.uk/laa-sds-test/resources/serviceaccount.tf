module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"
  serviceaccount_name = "laa-sds-serviceaccount-test"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-secure-document-storage-api"]
  github_environments = ["test"]

  github_actions_secret_kube_cert      = "TEST_KUBE_CERT"
  github_actions_secret_kube_token     = "TEST_KUBE_TOKEN"
  github_actions_secret_kube_cluster   = "TEST_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "TEST_KUBE_NAMESPACE"
}
