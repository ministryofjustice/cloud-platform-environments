module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"
  serviceaccount_name = "laa-sds-serviceaccount-stg"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-secure-document-storage-api"]
  github_environments = ["staging"]

  github_actions_secret_kube_cert      = "STAGING_KUBE_CERT"
  github_actions_secret_kube_token     = "STAGING_KUBE_TOKEN"
  github_actions_secret_kube_cluster   = "STAGING_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "STAGING_KUBE_NAMESPACE"
}
