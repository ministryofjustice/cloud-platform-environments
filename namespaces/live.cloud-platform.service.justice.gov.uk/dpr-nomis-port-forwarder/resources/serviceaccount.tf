/*
 * When using this module through the cloud-platform-environments,
 * this variable is automatically supplied by the pipeline TF_VAR_kubernetes_cluster.
 *
*/
variable "kubernetes_cluster" {}

module "serviceaccount" {
  source = "../"

  namespace           = "dpr-nomis-port-forwarder"
  github_repositories = ["dpr-nomis-port-forwarder"]

  github_actions_secret_kube_cert      = "KUBE_PROD_CERT"
  github_actions_secret_kube_token     = "KUBE_PROD_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_PROD_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_PROD_NAMESPACE"  
}