module "serviceaccount" {
  source                               = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.4"
  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  serviceaccount_name                  = "moj-cloud-platform-github-actions-serviceaccount"
  github_actions_secret_kube_cert      = "MOJ_CP_KUBE_CA_CERT"
  github_actions_secret_kube_token     = "MOJ_CP_KUBE_TOKEN"
  github_actions_secret_kube_cluster   = "MOJ_CP_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "MOJ_CP_KUBE_NAMESPACE"
}
