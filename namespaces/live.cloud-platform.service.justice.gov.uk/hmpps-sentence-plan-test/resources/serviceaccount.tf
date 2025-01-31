module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  role_name                            = var.serviceaccount_role_name
  serviceaccount_rules                 = var.serviceaccount_rules
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_repositories                  = ["hmpps-arns-integrations-test-playwright-poc"]
}
