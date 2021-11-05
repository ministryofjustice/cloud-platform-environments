module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.2"

  namespace = var.namespace

  kubernetes_cluster = var.kubernetes_cluster

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["helloworld-poornima-dev"]


}


module "serviceaccount-live" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.2"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["helloworld-poornima-dev"]

  serviceaccount_name                  = "cd-serviceaccount-live"
  role_name                            = "serviceaccount-role-live"
  rolebinding_name                     = "serviceaccount-rolebinding-live"
  github_actions_secret_kube_namespace = "KUBE_NAMESPACE_LIVE"
  github_actions_secret_kube_cert      = "KUBE_CERT_LIVE"
  github_actions_secret_kube_token     = "KUBE_TOKEN_LIVE"
  github_actions_secret_kube_cluster   = "KUBE_CLUSTER_LIVE"
}


