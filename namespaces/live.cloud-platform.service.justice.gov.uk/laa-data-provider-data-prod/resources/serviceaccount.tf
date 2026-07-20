module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  #serviceaccount_name = "cd-serviceaccount"
  #role_name           = "serviceaccount-role"
  #rolebinding_name    = "serviceaccount-rolebinding"

  serviceaccount_token_rotated_date = "20-03-2026"
  serviceaccount_rules = var.serviceaccount_rules

  github_repositories = var.github_repository_names
  github_environments = [var.github_environment_name, "prod_auto_without_approval"]

  github_actions_secret_kube_cert      = "DPD_KUBE_CERT"
  github_actions_secret_kube_cluster   = "DPD_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "DPD_KUBE_NAMESPACE"
  github_actions_secret_kube_token     = "DPD_KUBE_TOKEN"
}

module "deployer_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "deployer-serviceaccount"
  role_name           = "deployer-role"
  rolebinding_name    = "deployer-rolebinding"

  serviceaccount_token_rotated_date = "20-07-2026"
  serviceaccount_rules = var.deployer_serviceaccount_rules

  github_repositories = var.github_repository_names
  github_environments = [var.github_environment_name]

  github_actions_secret_kube_cert      = "KUBE_CERT"
  github_actions_secret_kube_cluster   = "KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_NAMESPACE"
  github_actions_secret_kube_token     = "DEPLOYER_KUBE_TOKEN"
}

module "e2etester_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "e2etester-serviceaccount"
  role_name           = "e2etester-role"
  rolebinding_name    = "e2etester-rolebinding"

  serviceaccount_token_rotated_date = "20-07-2026"
  serviceaccount_rules = var.e2etester_serviceaccount_rules

  github_repositories = var.github_repository_names
  github_environments = [var.github_environment_name]

  github_actions_secret_kube_cert      = "KUBE_CERT"
  github_actions_secret_kube_cluster   = "KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_NAMESPACE"
  github_actions_secret_kube_token     = "E2ETESTER_KUBE_TOKEN"
}
