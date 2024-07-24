/*
 * When using this module through the cloud-platform-environments,
 * this variable is automatically supplied by the pipeline TF_VAR_kubernetes_cluster.
 *
*/
module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace           = "dpr-bodmis-port-forwarder"
  github_repositories = ["dpr-bodmis-port-forwarder"]
  kubernetes_cluster  = var.kubernetes_cluster
}