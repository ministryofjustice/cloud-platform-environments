module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["payforlegalaid"]
  github_environments = ["dev"]

  dev_kube_cert      = var.github_actions_secret_kube_cert
  dev_kube_token     = var.github_actions_secret_kube_token
  dev_kube_cluster   = var.github_actions_secret_kube_cluster
  dev_kube_namespace = var.github_actions_secret_kube_namespace

}
