/*
 * When using this module through the cloud-platform-environments,
 * this variable is automatically supplied by the pipeline TF_VAR_kubernetes_cluster.
 *
*/
module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace           = "dpr-nomis-port-forwarder"
  github_repositories = ["dpr-nomis-port-forwarder"]
  kubernetes_cluster  = var.kubernetes_cluster

  github_actions_secret_kube_cert      = "KUBE_PROD_CERT"
  github_actions_secret_kube_token     = "KUBE_PROD_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_PROD_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_PROD_NAMESPACE"
}